# Pager-Policy Rollout Review Log
Mercury Payments Ops — change-advisory archive for the failed pager-policy rollout (2026-Q1 through 2026-Q2).

## Executive Summary
The batch routing compiler has produced unsafe responder queues since the February rollout. How the compile is *meant* to behave — normalization, dedupe and its tie-breaks, interval and overlap semantics, domain ordering, policy resolution, attenuation, the responder debt ledger, unit and threshold math, scoring, priority and queue ordering — was settled incrementally by the change-advisory board, and those decisions live in the review entries below, not in any single summary. The February draft proposals were revisited during the 2026-05 review cycle and several were reversed; where a draft proposal and a later CAB decision disagree, the later decision governs. `/app/docs/shipping_contract.json` is the output contract only: it fixes file paths, schemas, exact key sets, identifier payloads and checksum encodings, not how the values are derived.

## February Draft Proposals (2026-02 — partly reversed)
The initial rollout draft circulated a set of compile-behavior proposals through CAB tickets in the 1900 range. Several did not survive review. They are archived in place below and marked superseded; the later CAB decisions govern.

## Change-Review Archive (2025-Q4 through 2026-Q2)
Routine entries are context only. LOG-ticketed proposal and decision quotes embedded in the entries are the authoritative record for compile behavior.

### Review entry 0001 — billing lane
Log shipment for ingest-relay finished in 1s over 20 batches (ticket LOG-8000); the manifest checksum matched the prior generation and no lag windows were re-stitched.

### Review entry 0012 — inventory lane
> **Rollout draft proposal (2026-02-09 - LOG-1903)** Dana: service labels are stable upstream; preserve their exact casing and do not fold aliases together *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0024 — auth lane
> **Rollout draft proposal (2026-02-11 - LOG-1907)** Dana: rows whose start_ms or end_ms will not parse as an integer should be dropped from the compile entirely *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0036 — inventory lane
> **Rollout draft proposal (2026-02-13 - LOG-1911)** Tomas: treat any non-empty `planned` string as true, including `false` and `no` *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0048 — auth lane
> **Rollout draft proposal (2026-02-16 - LOG-1914)** Tomas: when an batch_id repeats, keep the first row encountered and discard the rest *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0049 — billing lane
Log shipment for ingest-relay finished in 13s over 356 batches (ticket LOG-8048); the manifest checksum matched the prior generation and no lag windows were re-stitched.

### Review entry 0060 — inventory lane
> **Rollout draft proposal (2026-02-18 - LOG-1917)** Dana: treat all intervals as closed [start_ms, end_ms], so endpoint contact counts as overlap *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0072 — auth lane
> **Rollout draft proposal (2026-02-20 - LOG-1921)** Tomas: when suppress and boost spans intersect, the intersection stays with suppress — suppression is safety-critical *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-21 - LOG-1922)** Dana: for scoped attenuation (handoff, blackout, degrade), clip the all-scope compacted intervals and the matching-severity compacted intervals to the window separately, add the two clipped durations to get overlap_ms, and set segment_count to the total count of clips across both scopes — do not merge the two scopes together *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0084 — inventory lane
> **Rollout draft proposal (2026-02-23 - LOG-1924)** Dana: subtract the full handoff, blackout and degrade overlaps from billable time with no divisor *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-24 - LOG-1925)** Tomas: exception and attenuation unit counts should all round the same way — floor-divide every overlap (suppress, boost, handoff, blackout, degrade) by its unit size so the conversions stay consistent *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0096 — auth lane
> **Rollout draft proposal (2026-02-25 - LOG-1928)** Tomas: carry responder debt forward without any cap; long weekends should accumulate naturally *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-25 - LOG-1926)** Dana: responder-debt bookkeeping between a service's windows — decay carried debt by half the idle gap (`debt_in_ms = max(previous.debt_out_ms - idle_gap_ms divided by 2 rounding down, 0)`), credit `debt_adjusted_dispatchable_ms` with `debt_in_ms divided by 4 rounding down`, and on carry-out add `handoff_segment_count*15 + blackout_segment_count*20 + degrade_segment_count*10` with no separate maintenance-span credit *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-26 - LOG-1930)** Dana: the pressure probes should look back a flat 200ms — probe [end_ms-200, end_ms) for handoff, blackout and degrade alike — and each pressure score is (all_probe_ms divided by 40 rounding down) + (severity_probe_ms divided by 25 rounding down) + segment_count, uniform across the three domains *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-27 - LOG-1932)** Tomas: escalation_score should weight debt_adjusted_dispatchable_ms divided by 50 rounding down, batch_count once, critical_batch_count twice, and count each pressure score a single time rather than doubling any of them *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*
> **Rollout draft proposal (2026-02-28 - LOG-1934)** Tomas: queue admission thresholds — compute `effective_queue_min_ms = queue_min_effective_ms + suppress_units*suppress_penalty_ms - boost_units*boost_credit_ms` with no floor at that step, add the handoff, blackout and degrade unit penalties in turn, and apply the `min_queue_floor_ms` floor once at the very end to the final `dispatch_queue_min_ms` *(Superseded — reversed in the 2026-05 change review; see the matching decision entry.)*

### Review entry 0097 — billing lane
Log shipment for ingest-relay finished in 25s over 292 batches (ticket LOG-8096); the manifest checksum matched the prior generation and no lag windows were re-stitched.

### Review entry 0100 — inventory lane
> **Change-review decision (2026-04-02 - LOG-2102)** Dana: attenuation divides overlaps as handoff divided by 3 rounding down, blackout divided by 4 rounding down, degrade divided by 5 rounding down. *(Revised — see the 2026-05 change review.)*

### Review entry 0104 — auth lane
> **Change-review decision (2026-04-06 - LOG-2106)** Dana: responder debt decays by half the idle gap, caps at 2200, and credits segments at 15/20/10 for handoff/blackout/degrade. *(Revised — see the 2026-05 change review.)*

### Review entry 0108 — inventory lane
> **Change-review decision (2026-04-10 - LOG-2110)** Tomas: every unit conversion rounds down, including suppress units. *(Revised — see the 2026-05 change review.)*

### Review entry 0112 — auth lane
> **Change-review decision (2026-04-14 - LOG-2114)** Tomas: queue admission compares debt-adjusted dispatchability against effective_queue_min_ms alone; no further threshold escalation applies. *(Revised — see the 2026-05 change review.)*

### Review entry 0116 — inventory lane
> **Change-review decision (2026-04-18 - LOG-2118)** Dana: batch windows merge only when the next batch starts at or before the current window's end, with no grace interval. *(Revised — see the 2026-05 change review.)*

### Review entry 0117 — edge lane
> **Change-review decision (2026-04-20 - LOG-2127)** Dana: duplicate batchs are grouped by `batch_id` and the kept row is chosen by highest severity rank first, then max end_ms, then max start_ms; the planned flag does not enter the tie-break. *(Revised — see the 2026-05 change review.)*
> **Change-review decision (2026-04-22 - LOG-2131)** Tomas: scoped handoff/blackout/degrade overlap_ms is the SUM of the (service, all) clipped duration and the (service, max_severity) clipped duration, and segment_count is the total count of clips across both scopes; the two scopes are not unioned. *(Revised — see the 2026-05 change review.)*
> **Change-review decision (2026-04-24 - LOG-2133)** Tomas: where a suppress span and a boost span intersect, the shared duration counts toward suppression_overlap_ms and is excluded from boost_overlap_ms; suppress wins the intersection. *(Revised — see the 2026-05 change review.)*

### Review entry 0118 — notifications lane
> **Change-review decision (2026-04-26 - LOG-2135)** Dana: pressure divisors — `handoff_pressure_score` = (all_probe_ms divided by 25 rounding down) + (severity_probe_ms divided by 15 rounding down) + handoff_segment_count; `blackout_pressure_score` uses divided by 30 rounding down and divided by 20 rounding down; `degrade_pressure_score` uses divided by 28 rounding down and divided by 18 rounding down. *(Revised — see the 2026-05 change review.)*
> **Change-review decision (2026-04-28 - LOG-2137)** Tomas: `escalation_score` = (debt_adjusted_dispatchable_ms divided by 60 rounding down) + batch_count*2 + critical_batch_count*3 + severity_weight[max_severity]; the exception-balance, handoff, blackout and debt pressure terms are not part of it. *(Revised — see the 2026-05 change review.)*
> **Change-review decision (2026-04-30 - LOG-2139)** Dana: interval semantics are closed [start_ms, end_ms]; endpoint-only contact contributes 1ms of overlap. *(Revised — see the 2026-05 change review.)*

### Review entry 0119 — ledger lane
> **Change-review decision (2026-05-01 - LOG-2141)** Tomas: `planned` coercion treats any non-empty string as true, including `false` and `no`, and treats a numeric planned value of 2 as true. *(Revised — see the 2026-05 change review.)*
> **Change-review decision (2026-05-01 - LOG-2143)** Dana: `debt_adjusted_dispatchable_ms` = dispatchable_billable_duration_ms + (debt_in_ms divided by 4 rounding down). *(Revised — see the 2026-05 change review.)*

### Review entry 0120 — auth lane
> **Change-review decision (2026-05-02 - LOG-2201)** Ilya: canonical service labels are trimmed and lowercased, then folded through the alias table: `authentication` -> `auth`, `payments` -> `billing`, `search-api` -> `search`. This supersedes LOG-1903.

### Review entry 0812 — debt bench
> **Change-review decision (2026-05-16 - LOG-2242)** Ilya: the debt credit applied to the dispatchable duration was losing every partial step, so a debt carry smaller than one full step credited nothing. That credit now ROUNDS UP: `debt_adjusted_dispatchable_ms = dispatchable_billable_duration_ms + debt_in_ms divided by 5 rounding up`. The idle-gap decay (divided by 3, rounding down) and the debt_out cap recorded earlier are unchanged and still round down. This revises the floored credit in LOG-2236.

### Review entry 0816 — probe bench
> **Change-review decision (2026-05-17 - LOG-2246)** Dana: the blackout probe takes the same correction and no other: `blackout_pressure_score = (blackout_all_probe_ms divided by 36 rounding down) + blackout_severity_probe_ms divided by 24 rounding up + blackout_segment_count`. The degrade probe was reviewed in the same session and is deliberately left floored on both halves.

### Review entry 0818 — debt bench
> **Change-review decision (2026-05-17 - LOG-2248)** Ilya: the debt-in half of the debt pressure score ROUNDS UP while the debt-out half does not: `debt_pressure_score = (debt_out_ms divided by 80 rounding down) + debt_in_ms divided by 120 rounding up`. The 80 debt-out divisor is unchanged.

### Review entry 0821 — canonicalization bench
> **Change-review decision (2026-05-18 - LOG-2258)** Marta: duplicate-severity precedence is REVERSED. Incident reports that duplicate an existing `batch_id` frequently arrive from an automated escalator that inflates severity before a human has confirmed it, so taking the maximum severity was systematically over-escalating the queue. Where two rows share an `batch_id` and tie on `end_ms`, the row with the LOWER severity rank is now the one kept — minor beats major, major beats critical. The remaining keys of the LOG-2207 chain are unchanged and still run in the same order after this one: then prefer `planned == false`, then max `start_ms`, then max `service` lexicographically. Only the severity comparison direction changes. This reverses that step of LOG-2207.

### Review entry 0822 — routing bench
> **Change-review decision (2026-05-19 - LOG-2252)** Dana: handoff attenuation review found a scoped handoff overlap shorter than one full step was being absorbed without cost, so the handoff subtraction ROUNDS UP: `adjusted_billable_duration_ms = max(billable_duration_ms - handoff_overlap_ms divided by 2 rounding up, 0)`. This revises the floored form recorded in LOG-2208.

### Review entry 0824 — routing bench
> **Change-review decision (2026-05-19 - LOG-2254)** Dana: the blackout attenuation takes the same correction: `routed_billable_duration_ms = max(adjusted_billable_duration_ms - blackout_overlap_ms divided by 3 rounding up, 0)`. The degrade attenuation that follows it was reviewed in the same session and is deliberately left FLOORED at `degrade_overlap_ms divided by 4 rounding down`.

### Review entry 0826 — exception bench
> **Change-review decision (2026-05-20 - LOG-2256)** Ilya: boost units are counted the same way suppression units already are — `boost_units` = the boost overlap divided by the boost unit size, rounding up — because a partial boost window was previously granting no credit at all. The handoff, blackout and degrade unit counts keep their floors and are not affected by this entry.

### Review entry 0820 — audit bench
> **Change-review decision (2026-05-18 - LOG-2250)** Ilya: recording the rounding map settled across LOG-2224, LOG-2242, LOG-2246, LOG-2248, LOG-2252, LOG-2254 and LOG-2256 for the avoidance of doubt. Rounding in this compiler is NOT uniform and no divisor's direction may be inferred from any other, including between siblings in the same family: the suppression unit count and the four probe/unit families each carry their own direction, and the degrade and handoff probes stay floored where the blackout probe rounds up. Read each divisor's direction from its own governing decision. *(Revised on the degrade probe point — see LOG-2264.)*

### Review entry 0122 — search lane
> **Change-review decision (2026-04-16 - LOG-2116)** Dana: final queue ordering is priority tier, then dispatchable_billable_duration_ms descending, then service ascending — a short, coarse key that avoids the pressure-score comparisons. *(Revised — see the 2026-05 change review.)*

### Review entry 0137 — billing lane
> **Change-review decision (2026-05-02 - LOG-2202)** Ilya: allowed severities are critical, major, minor; anything else (or a missing value) becomes `minor`. Severity rank for comparisons is critical > major > minor.

### Review entry 0152 — auth lane
Lag-window stitching for cold-store applied the grace interval across 277 unplanned batches in us-west (ticket LOG-8151); per-severity intervals merged without changing downstream scoring.

### Review entry 0154 — search lane
> **Change-review decision (2026-05-03 - LOG-2204)** Priya: every millisecond field is coerced with int(str(value).strip()) with fallback 0. Unparseable rows are KEPT with the fallback value — they are not dropped. This supersedes LOG-1907.

### Review entry 0171 — checkout lane
> **Change-review decision (2026-05-03 - LOG-2205)** Priya: `planned` coercion: booleans — preserve the boolean value; strings — strip and lowercase; true, 1, and yes become true; every other string becomes false; other types — use Python bool(value): null and numeric 0 become false; nonzero numbers and other truthy values become true. For the summary, count canonical deduplicated rows whose normalized planned value is true; for example planned=2 is excluded and planned=null is not. This supersedes LOG-1911.

### Review entry 0188 — inventory lane
> **Change-review decision (2026-05-04 - LOG-2207)** Marta: duplicate batchs are grouped by `batch_id` and one row is kept per group. Tie-break chain, in order: max end_ms; then max severity rank; then prefer planned == false; then max start_ms; then max service lexicographically. This supersedes LOG-1914.

### Review entry 0199 — ledger lane
Planned-flag normalization on replica-feed coerced 55 mixed-type values from the us-east feed (ticket LOG-8198) and held them out of window construction while keeping them in the canonical count.

### Review entry 0205 — edge lane
> **Change-review decision (2026-05-04 - LOG-2208)** Marta: interval semantics: all source and overlap intervals are half-open [start_ms,end_ms); rows with end_ms <= start_ms are discarded. Overlap is max(0, min(end_a, end_b) - max(start_a, start_b)); endpoint-only contact contributes 0ms. This supersedes LOG-1917.

### Review entry 0222 — notifications lane
> **Change-review decision (2026-05-05 - LOG-2210)** Ilya: window construction uses unplanned batchs only; stitch rule: merge if next.start_ms <= current.end_ms + 30 — the 30ms grace interval is final and revises LOG-2118. Maintenance compaction: per service, merge touching intervals if next.start_ms <= current.end_ms. Exceptions compaction: per (service, action), merge touching intervals if next.start_ms <= current.end_ms. Scoped compaction: per (service, severity_scope), merge touching intervals if next.start_ms <= current.end_ms.

### Review entry 0239 — ledger lane
> **Change-review decision (2026-05-05 - LOG-2211)** Ilya: routing domains apply in the fixed order maintenance -> exceptions -> handoff -> blackout -> degrade. Exception actions are limited to suppress and boost; severity scopes are all, major, critical.

### Review entry 0246 — notifications lane
Blackout window on object-drain absorbed 16 degrade segments during the ap-northeast rollout (ticket LOG-8245); touching intervals compacted and the queue ordering was unchanged.

### Review entry 0256 — auth lane
> **Change-review decision (2026-05-06 - LOG-2213)** Nadia: scoped overlap for handoff, blackout and degrade: for handoff, blackout, and degrade, select compacted intervals for (service, all) and (service, window.max_severity), clip both sets to the batch window, discard zero-duration clips, union and compact the combined clips using the touching merge rule, then set overlap_ms to the union duration and segment_count to the number of combined union segments. Thus an all-scope clip ending at 240 and a matching-severity clip starting at 240 form one segment, not two.

### Review entry 0273 — billing lane
> **Change-review decision (2026-05-06 - LOG-2214)** Nadia: suppress/boost precedence: compute half-open suppress and boost overlap spans, union each action's spans independently, assign all boost union duration to boost_overlap_ms, and subtract the duration of the suppress/boost intersection from suppression_overlap_ms; boost therefore wins intersection time. This supersedes LOG-1921.

### Review entry 0290 — search lane
> **Change-review decision (2026-05-07 - LOG-2216)** Priya: attenuation chain: `billable_duration_ms` = max(duration_ms - maintenance_overlap_ms, 0); `adjusted_billable_duration_ms` = max(billable_duration_ms - (handoff_overlap_ms divided by 2 rounding down), 0); `routed_billable_duration_ms` = max(adjusted_billable_duration_ms - (blackout_overlap_ms divided by 3 rounding down), 0); `dispatchable_billable_duration_ms` = max(routed_billable_duration_ms - (degrade_overlap_ms divided by 4 rounding down), 0). The 2/3/4 divisors are final and revise LOG-2102. This supersedes LOG-1924.

### Review entry 0293 — edge lane
Debt-ledger review for audit-stream carried 1496ms residual into the next span and decayed the prior idle to zero (ticket LOG-8292); the sa-east handoff segments reconciled cleanly.

### Review entry 0307 — checkout lane
> **Change-review decision (2026-05-07 - LOG-2217)** Priya: field dependency review: billable_duration_ms depends only on duration_ms and maintenance_overlap_ms suppression_overlap_ms and boost_overlap_ms are tracked separately and do not directly change billable_duration_ms adjusted_billable_duration_ms depends only on billable_duration_ms and handoff_overlap_ms routed_billable_duration_ms depends only on adjusted_billable_duration_ms and blackout_overlap_ms dispatchable_billable_duration_ms depends only on routed_billable_duration_ms and degrade_overlap_ms.

### Review entry 0324 — inventory lane
> **Change-review decision (2026-05-08 - LOG-2219)** Marta: debt ledger: state is independent per normalized service; process each service's merged windows in start_ms ascending order after all attenuation fields are finalized. First window: idle_gap_ms=0, debt_in_ms=0. `idle_gap_ms`: for later windows max(current.start_ms-previous.end_ms,0). `debt_in_ms` = max(previous.debt_out_ms-(idle_gap_ms divided by 3 rounding down),0). `debt_adjusted_dispatchable_ms` = dispatchable_billable_duration_ms + (debt_in_ms divided by 5 rounding down). `debt_out_ms` = min(debt_in_ms + dispatchable_billable_duration_ms + handoff_segment_count*20 + blackout_segment_count*25 + degrade_segment_count*15, 2500). finalize debt_out_ms for one window before evaluating the next window in the same service. The one-third idle decay, the 2500 cap, and the 20/25/15 segment credits are final and revise LOG-2106. This supersedes LOG-1928.

### Review entry 0339 — checkout lane
Operator Marta confirmed the archive-sink cron drop-in fired under svc-logship and rotated its log with no privilege drop (ticket LOG-8338); 386 batches were written to the retry queue.

### Review entry 0341 — edge lane
> **Change-review decision (2026-05-09 - LOG-2221)** Nadia: approved policy baseline (integers, defaults for every field): `queue_min_effective_ms` = 234; `critical_p1_min_ms` = 280; `critical_threshold_ms` = 650; `high_threshold_ms` = 320; `no_overlap_high_duration_ms` = 450; `critical_count_for_critical` = 2; `no_overlap_bonus` = 4; `segment_bonus` = 1; `score_threshold_critical` = 38; `score_threshold_high` = 24; `suppress_penalty_ms` = 40; `boost_credit_ms` = 30; `suppress_unit_ms` = 50; `boost_unit_ms` = 50; `min_queue_floor_ms` = 120; `boost_force_critical_ms` = 140; `boost_high_relief_ms` = 40; `handoff_penalty_ms` = 35; `handoff_unit_ms` = 60; `handoff_force_critical_ms` = 59; `handoff_high_relief_ms` = 50; `blackout_penalty_ms` = 45; `blackout_unit_ms` = 70; `blackout_force_critical_ms` = 200; `blackout_high_relief_ms` = 55; `degrade_penalty_ms` = 30; `degrade_unit_ms` = 80; `degrade_force_critical_ms` = 170; `degrade_high_relief_ms` = 45. Severity weights default to critical=5, major=3, minor=1.

### Review entry 0358 — notifications lane
> **Change-review decision (2026-05-09 - LOG-2222)** Nadia: policy file resolution: normalize the source default object by starting from policies.defaults and replacing each present integer field after int coercion with fallback 0; merge severity_weight by replacing only present critical/major/minor entries. Overrides: resolve every service profile to a complete policy: start from the normalized default profile, apply the matching service_overrides[canonical_service] fields, and merge a partial severity_weight map by key; omitted fields must remain available and must never raise KeyError. Sparse sources: the default object and every service override may omit any field; all omitted fields fall back through the complete defaults above.

### Review entry 0375 — ledger lane
> **Change-review decision (2026-05-10 - LOG-2224)** Ilya: unit conversions: `suppress_units` is 0 when the suppression overlap is 0, otherwise the suppression overlap divided by the suppress unit size (treated as at least 1), rounding up. `boost_units`, `handoff_units`, `blackout_units` and `degrade_units` are each the corresponding overlap divided by that domain's unit size (treated as at least 1), rounding down. Note suppress rounds up; every other unit rounds down — this revises the all-floor rule in LOG-2110.

### Review entry 0386 — search lane
Retention sweep on edge-shipper in us-west expired 16 stale batches and left 315 governing ones (ticket LOG-8385); the pruned set reconciled against the sink with no dangling offsets.

### Review entry 0392 — auth lane
> **Change-review decision (2026-05-10 - LOG-2225)** Ilya: queue admission thresholds build in four steps: `effective_queue_min_ms` = max(queue_min_effective_ms + suppress_units*suppress_penalty_ms - boost_units*boost_credit_ms, min_queue_floor_ms); `adjusted_queue_min_ms` = effective_queue_min_ms + handoff_units*handoff_penalty_ms; `routed_queue_min_ms` = adjusted_queue_min_ms + blackout_units*blackout_penalty_ms; `dispatch_queue_min_ms` = routed_queue_min_ms + degrade_units*degrade_penalty_ms. A window enters the queue only when debt_adjusted_dispatchable_ms >= dispatch_queue_min_ms — the full four-step chain is final and revises LOG-2114.

### Review entry 0409 — billing lane
> **Change-review decision (2026-05-11 - LOG-2227)** Marta: pressure probes and scores: `exception_balance_score` = boost_units - suppress_units. Handoff probe [end_ms-180, end_ms+1), blackout probe [end_ms-240, end_ms+1), degrade probe [end_ms-210, end_ms+1). `handoff_pressure_score` = (all_probe_ms divided by 30 rounding down) + (severity_probe_ms divided by 20 rounding down) + handoff_segment_count; `blackout_pressure_score` = (all_probe_ms divided by 36 rounding down) + (severity_probe_ms divided by 24 rounding down) + blackout_segment_count; `degrade_pressure_score` = (all_probe_ms divided by 34 rounding down) + (severity_probe_ms divided by 23 rounding down) + degrade_segment_count; `debt_pressure_score` = (debt_out_ms divided by 80 rounding down) + (debt_in_ms divided by 120 rounding down).

### Review entry 0426 — search lane
> **Change-review decision (2026-05-11 - LOG-2228)** Marta: `escalation_score` = (debt_adjusted_dispatchable_ms divided by 60 rounding down) + batch_count*2 + critical_batch_count*3 + (maintenance_overlap_ms==0 ? no_overlap_bonus : 0) + maintenance_span_count*segment_bonus + severity_weight[max_severity] + exception_balance_score*2 + handoff_pressure_score*2 + blackout_pressure_score*2 + debt_pressure_score*2. `risk_vector` = escalation_score + blackout_pressure_score + (degrade_pressure_score * 2) + debt_pressure_score.

### Review entry 0433 — billing lane
Log shipment for ingest-relay finished in 19s over 244 batches (ticket LOG-8432); the manifest checksum matched the prior generation and no lag windows were re-stitched.

### Review entry 0443 — checkout lane
> **Change-review decision (2026-05-12 - LOG-2230)** Nadia: a window is priority critical when ANY of the following holds: max_severity == critical and debt_adjusted_dispatchable_ms >= critical_p1_min_ms; OR debt_adjusted_dispatchable_ms >= critical_threshold_ms; OR critical_batch_count >= critical_count_for_critical; OR escalation_score >= score_threshold_critical; OR boost_overlap_ms >= boost_force_critical_ms; OR handoff_overlap_ms >= handoff_force_critical_ms; OR blackout_overlap_ms >= blackout_force_critical_ms; OR degrade_overlap_ms >= degrade_force_critical_ms; OR debt_out_ms >= 900; OR risk_vector >= score_threshold_critical + 4.

### Review entry 0460 — inventory lane
> **Change-review decision (2026-05-12 - LOG-2231)** Nadia: when not critical, a window is priority high when ANY of the following holds: debt_adjusted_dispatchable_ms >= high_threshold_ms; OR batch_count >= 3 and max_severity in {major, critical}; OR maintenance_overlap_ms == 0 and duration_ms >= no_overlap_high_duration_ms; OR escalation_score >= score_threshold_high; OR exception_balance_score > 0 and debt_adjusted_dispatchable_ms >= max(high_threshold_ms - boost_high_relief_ms, 0); OR handoff_pressure_score > 0 and debt_adjusted_dispatchable_ms >= max(high_threshold_ms - handoff_high_relief_ms, 0); OR blackout_pressure_score > 0 and debt_adjusted_dispatchable_ms >= max(high_threshold_ms - blackout_high_relief_ms, 0); OR degrade_pressure_score > 0 and debt_adjusted_dispatchable_ms >= max(high_threshold_ms - degrade_high_relief_ms, 0); OR debt_pressure_score > 0 and debt_adjusted_dispatchable_ms >= max(high_threshold_ms - 35, 0); OR risk_vector >= score_threshold_high + 2. Otherwise priority falls back to medium.

### Review entry 0477 — edge lane
> **Change-review decision (2026-05-13 - LOG-2233)** Ilya: final queue ordering, applied strictly in sequence — this full 16-key order is final and revises the coarse 3-key ordering in LOG-2116: priority (critical > high > medium); then escalation_score desc; then handoff_pressure_score desc; then blackout_pressure_score desc; then degrade_pressure_score desc; then debt_pressure_score desc; then risk_vector desc; then exception_balance_score desc; then dispatchable_billable_duration_ms desc; then routed_billable_duration_ms desc; then adjusted_billable_duration_ms desc; then critical_batch_count desc; then maintenance_span_count desc; then batch_count desc; then service asc; then start_ms asc.

### Review entry 0480 — auth lane
Lag-window stitching for cdn-flush applied the grace interval across 173 unplanned batches in ap-northeast (ticket LOG-8479); per-severity intervals merged without changing downstream scoring.

### Review entry 0491 — checkout lane
> **Change-review decision (2026-05-16 - LOG-2236)** Marta: closing the extended-quiet thread from the 0491 review — proportional decay leaves stale debt on the books when a service goes quiet for a long stretch, so the ledger now resets outright past a threshold: when `idle_gap_ms` is 600 or greater, `debt_in_ms` is 0 for that window instead of `max(previous.debt_out_ms - (idle_gap_ms divided by 3 rounding down), 0)`. Below 600 the one-third decay stands exactly as written. This reset revises LOG-2219; the 2500 cap and the 20/25/15 segment credits there are unaffected.

### Review entry 0493 — edge lane
> **Change-review decision (2026-05-18 - LOG-2251)** Marta: the maintenance-window review closed on this lane with one ledger change — a window that overlapped planned maintenance still leaves residual responder debt, and carrying nothing for it understated the next window's position. Each maintenance span now carries a credit alongside the existing ones: `debt_out_ms = min(debt_in_ms + dispatchable_billable_duration_ms + maintenance_span_count*12 + handoff_segment_count*20 + blackout_segment_count*25 + degrade_segment_count*15, 2500)`. The 12-point maintenance credit revises LOG-2219; the 20/25/15 credits, the one-third idle decay and the 2500 cap recorded there are unchanged, as is the extended-idle reset in LOG-2236.

### Review entry 0510 — notifications lane
> **Change-review decision (2026-05-25 - LOG-2240)** Priya: responder dashboards retain ninety days of window history; older windows are served from the artifact archive on demand. Dashboard retention is an operational setting and carries no weight in compile output.
> **Change-review decision (2026-05-28 - LOG-2243)** Marta: artifact bundles must record output signatures at export time and again at archive ingest; a mismatch quarantines the bundle for manual review. Evidence handling only; artifact contents are unaffected.

### Review entry 0527 — auth lane
Planned-flag normalization on tls-audit coerced 19 mixed-type values from the sa-east feed (ticket LOG-8526) and held them out of window construction while keeping them in the canonical count.

### Review entry 0528 — billing lane
> **Change-review decision (2026-06-03 - LOG-2262)** Dana: quarterly access recertification for the routing path samples service-to-service grants at twice the standard rate through year end. Access policy; no compiler impact.
> **Change-review decision (2026-05-30 - LOG-2264)** Marta: degrade probe rounding, and the rounding map of record. The SEVERITY-scoped half of the degrade probe now ROUNDS UP (ceiling) while the all-scoped half keeps its floor: `degrade_pressure_score = (degrade_all_probe_ms divided by 34 rounding down) + degrade_severity_probe_ms divided by 23 rounding up + degrade_segment_count`. This revises the floored `degrade_severity_probe_ms divided by 23 rounding down` written in LOG-2227, which is superseded on this point only: the probe range [end_ms-210, end_ms+1), the divisors 34 and 23, the all-scoped floor and the segment term are unchanged. This entry also supersedes LOG-2250 as the rounding map of record: rounding remains NON-uniform and no divisor's direction may be inferred from any other, but the degrade probe no longer stays floored on both halves — only the handoff probe does. Read each divisor's direction from its own governing decision.

### Review entry 0546 — edge lane
> **Change-review decision (2026-06-06 - LOG-2249)** Ilya: the weekly CAB digest becomes a standing publication with a superseded-by column. Communications practice only; the ticketed decisions remain the sole authority on compile behavior.
