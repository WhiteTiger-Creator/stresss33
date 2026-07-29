# Outage Compile — Deployment Runbook

Operational deployment contract for the batch routing compile on responder hosts. This document defines the required deployment state; the compile's output contract lives in `shipping_contract.json` and its behavioral record in the rollout review log.

## Service account

The *scheduled* compile runs under the dedicated system account `svc-logship` — that identity is selected by the cron drop-in below (the user field of the cron line), not by the wrapper. The account has no interactive login shell (`/usr/sbin/nologin`).

## Wrapper

Operations invokes the compiler only through `/usr/local/bin/ship-logs`:

- mode `0755`, owned by root
- forwards all arguments to `python3 /app/workflow/log_ship.py`
- runs the compiler **as the invoking user**: the wrapper must not switch user, `su`, `sudo`, `setpriv`, `setuid`, or otherwise drop privileges — selecting the `svc-logship` identity is the cron drop-in's job, not the wrapper's. Invoked directly (e.g. by an operator or in a check), the wrapper runs the compiler as whoever ran it.
- concurrency guard: when the lock file `/var/lock/log-shipper.lock` exists, the wrapper must exit with status `75` (EX_TEMPFAIL) without invoking the compiler or writing any output. The lock path is **exactly** `/var/lock/log-shipper.lock` — not a variant such as `log-shipper.compile.lock` or one derived from the log file name; the wrapper checks and honours that one path.

Stale locks left behind by crashed runs are removed during recovery, not worked around.

## Schedule

The compile is scheduled through a cron drop-in at `/etc/cron.d/log-shipper`, mode `0644`, containing exactly this job line and nothing more — the line ends at `/app/output`, with **no** appended output redirection (no ` >> …`, no ` 2>&1`, no `MAILTO`), and no trailing comment:

```
*/5 * * * * svc-logship /usr/local/bin/ship-logs --input /app/data/batches.json --output-dir /app/output
```

## Output directory

`/app/output` is owned `svc-logship:svc-logship` with mode `0750`. World-writable output directories are a rollout defect and must not survive recovery.

## Log directory

The compile writes its run log under `/var/log/log-shipper`. The directory is owned `svc-logship:svc-logship` with mode `0750`; a world-writable log directory is a rollout defect and must not survive recovery. The crashed rollout also left an unrotated leftover at `/var/log/log-shipper/compile.log.0` — recovery prunes rollout leftovers rather than leaving them for the next rotation. The live `compile.log` itself stays in place.

## Log rotation

Rotation is configured by a drop-in at `/etc/logrotate.d/log-shipper`, mode `0644`, owned root, covering `/var/log/log-shipper/*.log` and declaring exactly these directives:

```
/var/log/log-shipper/*.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    su svc-logship svc-logship
    create 0640 svc-logship svc-logship
}
```

Rotation runs as the service account, not as root: the `su` and `create` lines are what keep rotated files owned by `svc-logship`.
