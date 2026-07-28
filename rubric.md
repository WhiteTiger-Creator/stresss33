# Rubric — Batch Routing Rollup Recovery (LOG)

## Core compiler algorithm (the load-bearing work)

Agent normalizes each row before anything else: canonical service label per the governing LOG casing/alias ruling, integer coercion of start_ms/end_ms with the governed fallback (rows are not silently dropped), and the governed `planned`/severity coercion (only the governed truthy set counts), ±3
Agent deduplicates repeated batch_id rows by the governed tie-break chain in order (not by input order), so which of two competing rows survives is deterministic and matches the later CAB decision, not the reversed February draft, ±3
Agent builds and compacts intervals per the governed stitch/overlap semantics — merging or separating windows at the exact governed gap threshold and counting segments/spans as the governing ruling specifies, ±3
Agent applies the NON-UNIFORM attenuation rounding exactly: each attenuation family (handoff, blackout, degrade, exception units) uses its OWN governed rounding direction and divisor — some ceil, some floor — and does not assume a single uniform direction across families, ±5
Agent computes the responder debt ledger per the governing decisions: carry-in decayed by the governed idle rule, the ceil/floor of each carry term as governed, the segment credits, and the carry-out cap — carrying state correctly between consecutive windows of a service, ±5
Agent computes scoring and queue admission on the conditioned windows: effective/suppress/boost units, the pressure and threshold math, and admits a window only when the governed dispatch floor is met, so queue membership matches exactly, ±3
Agent orders the final queue by the full governed key sequence and applies any per-domain cap by the global order, producing byte-identical `alert_queue`/queue rows, ±3

## Governance discipline

Agent applies the FINAL governing LOG decisions (per governing_entry_index) and ignores the reversed February drafts, resolving overlaps by the later dated decision, ±3
Agent derives every value from the inputs and the governing rulings — never hardcoding or copying any precomputed or expected-output value, ±2
Agent leaves the frozen reference snapshot unchanged and produces deterministic, idempotent output identical across reruns, ±2
Agent produces correct output on an alternate batch input it has not seen, ±2

## Host recovery (secondary)

Agent restores the deployment host state the runbook specifies — service account, wrapper, cron, output/log ownership and modes, rotation, and cleanup of the crashed run's stale lock and unrotated leftover, ±2
