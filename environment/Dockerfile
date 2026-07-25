FROM public.ecr.aws/docker/library/python:3.13-slim-bookworm@sha256:01f42367a0a94ad4bc17111776fd66e3500c1d87c15bbd6055b7371d39c124fb

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tmux \
        asciinema \
        cron \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.lock /tmp/requirements.lock
RUN python3 -m pip install --no-cache-dir --no-deps \
        -r /tmp/requirements.lock

WORKDIR /app

COPY app/ /app/
RUN cp /app/workflow/log_ship.py /app/workflow/.log_ship.original \
    && chmod a-w /app/workflow/.log_ship.original

# Operational wiring left behind by the failed pager-policy rollout:
# a non-executable wrapper pointing at a path that no longer exists, a stale
# compile lock, no schedule entry, and a world-writable output directory.
RUN printf '#!/bin/sh\nexec python3 /app/workflow/log_ship.py.legacy "$@"\n' > /usr/local/bin/ship-logs \
    && chmod 0644 /usr/local/bin/ship-logs \
    && mkdir -p /var/lock \
    && printf '4711\n' > /var/lock/log-shipper.lock \
    && rm -f /etc/cron.d/log-shipper \
    && mkdir -p /app/output \
    && chmod 0777 /app/output

# Log wiring the rollout also left wrong: the compile log directory is world-writable
# and still root-owned, its rotation drop-in was never installed, and an unrotated
# leftover from the crashed run is still sitting in the directory.
RUN mkdir -p /var/log/log-shipper \
    && chmod 0777 /var/log/log-shipper \
    && printf 'rollout 4711 aborted mid-compile\n' > /var/log/log-shipper/compile.log.0 \
    && printf '' > /var/log/log-shipper/compile.log \
    && rm -f /etc/logrotate.d/log-shipper
