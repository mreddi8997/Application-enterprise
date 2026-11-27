"""Load Petclinic's PostgreSQL credentials for systemd without storing them in Terraform."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from urllib.request import urlopen


CONFIG_PATH = Path("/etc/petclinic/database.json")
RUNTIME_DIR = Path("/run/petclinic-db")
RDS_CA_URL = "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"


def read_secret(config):
    response = subprocess.check_output(
        [
            "aws", "--no-cli-pager", "--region", config["region"],
            "--cli-connect-timeout", "5", "--cli-read-timeout", "10",
            "secretsmanager", "get-secret-value", "--secret-id", config["secret_arn"],
            "--query", "SecretString", "--output", "text",
        ],
        stderr=subprocess.DEVNULL,
        timeout=40,
    )
    return json.loads(response)


def env_value(value):
    if not isinstance(value, str) or not value or "\0" in value:
        raise ValueError("Expected a nonempty environment variable value.")
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return '"' + escaped + '"'


def write_file(path, data, mode=0o600):
    descriptor, filename = tempfile.mkstemp(dir=path.parent)
    temp_path = Path(filename)
    try:
        with os.fdopen(descriptor, "wb") as temp:
            temp.write(data)
        temp_path.chmod(mode)
        temp_path.replace(path)
    finally:
        temp_path.unlink(missing_ok=True)


def main():
    config = json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    secret = read_secret(config)
    environment = {
        "SPRING_PROFILES_ACTIVE": "postgres",
        "SPRING_SQL_INIT_MODE": "never",
        "POSTGRES_URL": config["jdbc_url"],
        "POSTGRES_USER": secret["username"],
        "POSTGRES_PASS": secret["password"],
    }
    contents = "\n".join(f"{key}={env_value(value)}" for key, value in environment.items())

    RUNTIME_DIR.mkdir(mode=0o755, exist_ok=True)
    RUNTIME_DIR.chmod(0o755)
    ca_path = RUNTIME_DIR / "rds-ca.pem"
    if not ca_path.is_file():
        with urlopen(RDS_CA_URL, timeout=15) as response:
            write_file(ca_path, response.read(), mode=0o644)

    # systemd reads this file immediately before starting the application.
    write_file(RUNTIME_DIR / "database.env", (contents + "\n").encode("utf-8"))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError):
        print("Unable to load Petclinic database settings or the RDS CA bundle.", file=sys.stderr)
        sys.exit(1)
