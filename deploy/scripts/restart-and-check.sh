#!/usr/bin/env bash
set -euo pipefail

systemctl restart petclinic.service

for attempt in {1..30}; do
  if systemctl is-active --quiet petclinic.service &&
     curl --fail --silent --max-time 2 http://127.0.0.1:8080/ >/dev/null; then
    echo "Petclinic is serving HTTP requests."
    exit 0
  fi
  sleep 2
done

journalctl -u petclinic.service -n 30 --no-pager >&2
exi
