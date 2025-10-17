# benchmarks

This folder contains guidance and helpers for running microbenchmarks for CRZ64I simulators or emulator targets.

Benchmarking protocol (minimal):

1. Prepare a deterministic input set and log environment (CPU model, kernel, host clocks).
2. Run each kernel in isolation (single-thread and multi-thread modes) and collect: cycles, instructions (if available), cache-misses.
3. Use `RDT` inside simulated code and `perf stat` on host-side simulator binary for correlation.
4. Store raw results in JSON with fields: op, cycles_per_op, latency_ns, energy_pJ (optional), speed_ops_per_sec, duration_ns, heat_pJ, temp_delta

Recommended columns for result JSON (per op):
- op
- cycles_per_op
- latency_ns
- energy_per_op_picojoules
- speed_ops_per_sec
- duration_ns
- heat_picojoules
- temp_delta

Validation: provide `validate.sh` to sanity-check ranges and ensure non-negative and plausible numbers.

Tools & tips:
- If you have a simulator `./sim`, use `perf stat -e cycles,cache-misses ./sim <bench>` to correlate counters.
- Use small warm-up runs and then measure multiple iterations to compute median and standard deviation.
- Pin threads to cores when measuring multi-thread runs (taskset).
