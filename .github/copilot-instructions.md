# CRZ64I Assembly Language - AI Contribution Guidelines

## Project Overview
CRZ64I is a cutting-edge assembly language designed for high-performance, low-latency computing with a focus on concurrency, AI/ML operations, and deterministic real-time execution. The instruction set consists of 64 carefully selected core instructions optimized for single-cycle execution.

## Key Architecture Concepts

### 1. Instruction Categories
- **Atomic Operations (10)**: Core synchronization primitives (e.g., `XCHG`, `FADD.ATM`, `CASX`)
- **Memory Access (7)**: Fast memory operations (`LOAD`, `STORE`, `PREF`)
- **Mathematical/Logical (20)**: Optimized compute operations (`FMA`, `ADD`, `SEL`)
- **Vector/SIMD (7)**: AI/ML acceleration (`VADD.128`, `VDOT32`)
- **Thread Management (7)**: Lightweight concurrency (`THREAD_CREATE`, `MSG_SEND`)
- **Memory Management (5)**: Deterministic control (`MBAR`, `CACHE_LOCK`)
- **Timing/Counters (3)**: Performance monitoring (`RDT`, `PERF_READ`)
- **Crypto/Hash (3)**: Security operations (`HASH.ACC`, `AES.RND`)
- **I/O and DMA (4)**: Non-blocking operations (`BLIT_START`)
- **System (1)**: OS interaction (`SYS_CALL`)

### 2. Design Principles
- Single-cycle execution priority
- Relaxed memory model with explicit ordering control
- Lock-free algorithms through atomic primitives
- SIMD-first approach for data parallelism
- Deterministic real-time guarantees

## Development Patterns

### 1. Atomic Operations
```assembly
; Example: Lock-free counter increment
AINC [counter_addr] -> old    ; Atomic increment, returns old value
; No need for explicit locks or critical sections
```

### 2. Vectorized Processing
```assembly
; Example: Vector dot product with parallel execution
THREAD_CREATE t1, dot_prod, stack1
VDOT32 vdst, va, vb          ; 32-bit elements dot product
MSG_SEND result_tid, vdst, 4  ; Send result to aggregator
```

### 3. Memory Synchronization
```assembly
; Example: Memory barrier for ordering
STORE [addr], value          ; Store value
# CRZ64I Assembly Language - AI Contribution Guidelines

## Project Overview
CRZ64I is a research-focused assembly ISA optimized for single-cycle primitives, low-latency concurrency, and SIMD-first AI/ML kernels. This repository contains the ISA design notes, instruction catalog, small examples, and tooling stubs used by compilers and simulators. AI coding agents should treat the spec as evolving: prefer small, well-documented edits and incremental examples rather than large redesigns.

## Key Architecture Concepts

### 1. Instruction Categories
- **Atomic Operations (10)**: Core synchronization primitives (e.g., `XCHG`, `FADD.ATM`, `CASX`)
- **Memory Access (7)**: Fast memory operations (`LOAD`, `STORE`, `PREF`)
- **Mathematical/Logical (20)**: Optimized compute operations (`FMA`, `ADD`, `SEL`)
- **Vector/SIMD (7)**: AI/ML acceleration (`VADD.128`, `VDOT32`)
- **Thread Management (7)**: Lightweight concurrency (`THREAD_CREATE`, `MSG_SEND`)
- **Memory Management (5)**: Deterministic control (`MBAR`, `CACHE_LOCK`)
- **Timing/Counters (3)**: Performance monitoring (`RDT`, `PERF_READ`)
- **Crypto/Hash (3)**: Security operations (`HASH.ACC`, `AES.RND`)
- **I/O and DMA (4)**: Non-blocking operations (`BLIT_START`)
- **System (1)**: OS interaction (`SYS_CALL`)

### 2. Design Principles
- Single-cycle execution priority: most core instructions are conceptualized to complete in 1 cycle. When modelling latency in software or a simulator, use 1 cycle as the baseline and document any deviations.
- Relaxed memory model with explicit ordering control: default loads/stores are relaxed; use `MBAR`/`ATOMIC_BEGIN`/`ATOMIC_END` when ordering is required.
- Lock-free primitives: prefabricated atomics (AINC, CASX, LR/SC) are preferred synchronization building blocks. Implementations should avoid heavyweight locks where possible.
- SIMD-first: vector instructions (VLOAD, VADD.128, VDOT32) are central — data-layout and alignment matter.
- Deterministic RT behavior: `CACHE_LOCK`, `TLB_INV`, and `MBAR` exist to help deterministic execution; document where determinism is necessary.

## CRZ64I — concise AI contribution guide

This file tells AI coding agents the minimal, concrete knowledge needed to be productive in this repository.

Key facts (big picture)
- CRZ64I is an ISA repo: opcode catalog, small examples in `examples/`, and microbenchmarks in `benchmarks/` (and `bench/`).
- Baseline assumption: many core ops are modelled as single-cycle; real hardware deviations are documented in benchmarks and config files (see `bench/` and `CRZ64I_ISA_TABLE.csv`).

Where to start
- Read `README.md`, `CRZ64I_ISA_TABLE.csv` and `examples/` to learn opcode names and register conventions.
- Use `bench/collect_benchmarks.py` and `bench/rdtsc_bench_template.c` (if present) for measurement workflows — results are written to `bench/benchmark_results/`.

Important repo conventions
- All examples use R0–R7 as GPRs and V0–V7 for vector regs. R0–R2 are function arguments; R6–R7 are callee-saved.
- Memory model is relaxed by default; use `MBAR`/`ATOMIC_BEGIN`/`ATOMIC_END` for ordering.
- Prefer lock-free atomics (AINC, CASX, LR/SC) for concurrency examples.

Developer workflows (practical)
- Run and collect microbenchmarks: inspect `bench/collect_benchmarks.py` to compile per-op benches and write CSVs. Bench harnesses use RDT/RDTSCP-style timing; prefer CPU governor=performance for repeatability.
- Add examples under `examples/` (keep them small, 1–4 files). Add microbenchmarks under `bench/` or `benchmarks/` and produce JSON/CSV outputs alongside raw counters.

Patterns to preserve and use in edits
- Small, well-documented changes only — avoid large ISA redesigns. Add opcode snippets that follow register conventions and show alignment for vector ops.
- For new benchmarks, implement a precise measurement pattern: serialize, warm-up, measure, and store raw counters + derived metrics (cycles, ns, ops/sec).

Integration points
- `examples/` for usage patterns; `bench/` for measurement harness; `Instructions.md` (or `README.md`) is canonical doc for opcode semantics. Use `bench/benchmark_results/` as the canonical output location.

When you commit changes
- Include: short description, files touched, and a note if results change (benchmarks) or semantics change (opcodes).

If something is missing
- Ask for the authoritative 65-op list or the target measurement machine details (CPU model, governor, any sensors) before creating or changing large benchmark runs.

Questions or unclear areas — ask the maintainer for:
- authoritative opcode list to use for microbenchmarks, and
- which hardware counters / sensors are available on the test machine (RAPL, thermal sensors) for energy/heat reporting.

That's it — I kept the canonical tips and file pointers from the original doc but trimmed examples and long background. If you want, I can expand this with a 6–10 line quickstart for running the collector and a minimal PR checklist.
