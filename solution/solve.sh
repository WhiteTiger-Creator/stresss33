#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Inspect before changing anything (read-only) ---
# Read the deployment state the runbook requires.
cat /app/docs/deployment_runbook.md || true

# Read the output contract: schemas, key sets, identifier payloads, checksum encodings.
python3 -c "import json;print(json.dumps(json.load(open('/app/docs/shipping_contract.json')),indent=2))"

# Locate the governing CAB entries. The log is long and mostly routine, so index the
# ticketed decisions first, then read the ones that govern each stage.
grep -n "LOG-" /app/batch/shipping_review_log.md | head -60 || true

# Confirm which entries are superseded rather than governing.
grep -n "Superseded\|Revised" /app/batch/shipping_review_log.md | head -20 || true

# Inspect the current host state and the broken compiler before touching either.
ls -la /usr/local/bin/ship-logs /var/lock /app/output 2>&1 || true
getent passwd svc-logship || echo "svc-logship not provisioned"
ls -la /etc/cron.d/ 2>&1 || true
sed -n '1,60p' /app/workflow/log_ship.py || true

# Read the operational inputs the compile reconciles.
ls -la /app/data || true
python3 -c "import json;d=json.load(open('/app/data/batches.json'));print(len(d),'batch rows')"

# --- Restore the deployment state defined in /app/docs/deployment_runbook.md ---

# Dedicated service account with no interactive shell.
if ! getent passwd svc-logship >/dev/null; then
  useradd --system --shell /usr/sbin/nologin svc-logship
fi

# Operator wrapper: executable, targets the live compiler, honors the lock.
cat > /usr/local/bin/ship-logs <<'EOF'
#!/bin/sh
LOCK=/var/lock/log-shipper.lock
if [ -e "$LOCK" ]; then
  echo "batch compile blocked by existing lock: $LOCK" >&2
  exit 75
fi
exec python3 /app/workflow/log_ship.py "$@"
EOF
chmod 0755 /usr/local/bin/ship-logs

# Clear the stale lock left by the crashed rollout.
rm -f /var/lock/log-shipper.lock

# Reinstate the schedule.
printf '*/5 * * * * svc-logship /usr/local/bin/ship-logs --input /app/data/batches.json --output-dir /app/output\n' \
  > /etc/cron.d/log-shipper
chmod 0644 /etc/cron.d/log-shipper

# Output directory ownership and mode per runbook.
mkdir -p /app/output
chown svc-logship:svc-logship /app/output
chmod 0750 /app/output

# Log directory per runbook: prune the rollout leftover, then hand the directory to
# the service account and drop the world-writable mode.
mkdir -p /var/log/log-shipper
rm -f /var/log/log-shipper/compile.log.0
chown -R svc-logship:svc-logship /var/log/log-shipper
chmod 0750 /var/log/log-shipper

# Rotation drop-in. The su/create lines keep rotated files owned by svc-logship.
cat > /etc/logrotate.d/log-shipper <<'ROTEOF'
/var/log/log-shipper/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    su svc-logship svc-logship
    create 0640 svc-logship svc-logship
}
ROTEOF
chmod 0644 /etc/logrotate.d/log-shipper

# --- Restore the compiler itself and produce the responder outputs ---

cp "${SCRIPT_DIR}/log_ship_fixed.py" /app/workflow/log_ship.py
chmod +x /app/workflow/log_ship.py

/usr/local/bin/ship-logs --input /app/data/batches.json --output-dir /app/output
