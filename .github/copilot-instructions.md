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

## Development Patterns (practical)

Below are concrete idioms you'll use or generate when authoring examples, tests, or simulator support code.

### 1. Atomic Operations (idioms)
Use atomics as building blocks for lock-free structures. Prefer the smallest semantic primitive that expresses the intent (AINC for counters, CASX for complex conditional updates).

Example: atomic push to a singly-linked stack (lock-free, simplified):

```assembly
; r0 = new_node_addr, r1 = &stack_head
LR [r1], r2         ; load head into r2 with reservation
STORE [r0], r2      ; new_node->next = old_head
SC [r1], r0 -> ok    ; try to swap head to new_node
SEL r3, ok, r0, r2  ; if ok keep new head in r3, else r3 = r2 (loop externally)
```

Note: Use an external loop around LR/SC or CASX to retry on failure; this keeps the hardware-friendly pattern.

### 2. Vectorized Processing
Vectors assume packed layouts (32-bit lanes for VDOT32). Keep alignment to 128-bit boundaries when using `VLOAD/VSTORE` to avoid splits.

Example: single-thread dot-product of 4 lanes (pseudo-ISA):

```assembly
; r0 = src_a, r1 = src_b, v0 = accumulator (zeroed)
VLOAD v1, [r0]       ; load 4x32 from src_a
VLOAD v2, [r1]       ; load 4x32 from src_b
VDOT32 v0, v1, v2    ; v0 = sum(a[i]*b[i]) across lanes
VSTORE [r2], v0      ; store scalar result (lane0) to r2
```

Parallel pattern (worker threads + aggregator): use `THREAD_CREATE` for workers, `MSG_SEND` to push partial sums, then aggregator `MSG_RECV` + final reduction.

### 3. Memory Synchronization
Use `MBAR` when ordering between independent cores/components is required. For short critical sections, LR/SC or CASX loops are preferred over full barriers.

Example: ordered store then dependent load:

```assembly
STORE [addr], r0
MBAR FULL
LOAD r1, [addr2]
```

## Common Integration Points

1. **Thread Communication**
   - Use `MSG_SEND`/`MSG_RECV` for lightweight message passing
   - Prefer atomic operations over locks where possible
   - `THREAD_JOIN` for synchronization points

2. **Real-time Operations**
   - `CACHE_LOCK` for deterministic memory access
   - `RDT` for precise timing measurements
   - `PARK` for power-efficient waiting

3. **AI/ML Acceleration**
   - Vector operations (`VADD.128`, `VDOT32`)
   - Parallel reduction using atomic min/max
   - DMA for efficient data movement

Practical note: typical ML kernels copy input tensors into contiguous, aligned buffers (128-bit) and use `BLIT_START` to pre-stage data into local memory. When simulating performance, include prefetching (`PREF`) and account for store-forwarding costs on misaligned accesses.

## Performance Considerations

1. **Memory Access Patterns**
   - Use `PREF` for predictable memory access
   - Align data for vector operations
   - Consider cache line boundaries

Practical metrics guidance:
- When benchmarking or modelling, assume 1 cycle for core ops. Add cost for memory access depending on model: L1 hit ~4 cycles, L2 ~12 cycles, memory ~100 cycles (document your model in the benchmark README).
- Use `PERF_READ` and `RDT` in examples to measure and log cycles. Store raw counters alongside computed metrics so agents can validate results.

2. **Atomic Operations**
   - Prefer simple atomics (`AINC`) over complex ones (`CASX`)
   - Use `SEL` for branchless conditionals
   - Combine `LR`/`SC` for complex atomic updates

3. **Thread Management**
   - Balance thread count with available cores
   - Use message passing for inter-thread communication
   - Consider thread parking for power efficiency

## Known Patterns

### Efficient Synchronization
```assembly
; Example: Lock-free queue operation
LR [head], r1              ; Load head with reservation
; ... process queue ...
SC [head], r2 -> success   ; Try to update head
; Retry if needed
```

Example: CAS-based spin-lock (simple):

```assembly
; r0 = lock_addr
1: LOAD r1, [r0]
   CMP r1, #0
   SEL r2, cond_zero, #1, r1  ; branchless choose 1 if zero
   CASX [r0], r1, r2 -> ok
   IF !ok GOTO 1
```

### Vectorized Data Processing
```assembly
; Example: Parallel array processing
VLOAD v1, [src]           ; Load vector
VADD.128 v2, v1, vconst   ; Vector add
VSTORE [dst], v2          ; Store result
```

## Project-Specific Conventions

1. **Register Usage**
   - R0-R7: General purpose
   - V0-V7: Vector registers
   - Special: SP (stack), PC (program counter)

Convention notes for contributors:
- Use R0-R2 for function-like argument passing in examples. R6-R7 are callee-saved in our test harnesses.
- Vector registers V0-V3 are preferred for temporary computations; reserve V4-V7 for persistent scratch across calls.

2. **Memory Ordering**
   - Default: Relaxed ordering
   - Use `MBAR` for explicit ordering requirements
   - `ATOMIC_BEGIN`/`END` for transaction hints

3. **Error Handling**
   - Use `flag` returns for operation status
   - `SYS_CALL` for system-level errors
   - Hardware exceptions for critical failures

## Debugging Tips

1. **Performance Monitoring**
   - Use `PERF_READ` for hardware counter access
   - `RDT` for precise timing measurements
   - Profile atomic operation patterns

Additional debugging & validation workflow

- Emulate first: this repo assumes simulators/emulators will be used to validate ISA semantics before hardware testing. If a simulator exists under `tools/` or `sim/`, prefer adding tests that run there.
- Use host tools for performance correlation: `perf stat -e cycles,cache-misses ./sim` to collect counters if running a simulator binary.
- Validation: store both raw counters and normalized metrics (ops/sec, latency_ns) in JSON alongside each benchmark. Include a `validate.py` or `validate.sh` helper (suggested) that checks values are within expected ranges.
- Reproducible runs: pin seeds for PRNG (`RNG dst, seed_mode`) in microbenchmarks and log environment (CPU model, kernel version) in the benchmark output.

File references and targets to edit when adding tests/examples:
- `Instructions.md` — canonical opcode documentation
- `examples/` — place short, self-contained snippets here (1-4 files per category)
- `benchmarks/` — microbenchmarks and JSON results
- `tools/sim/` — simulator or emulation harness (if present)

For comprehensive examples and integration patterns, refer to the [examples/](examples/) directory.

---

If you'd like, I can now:
1. Add 6 concrete example files under `examples/` (atomics, vector, threading, DMA, memory-barrier, hash), and
2. Add a `benchmarks/README.md` describing a minimal benchmark protocol and a small `validate.sh` script to verify collected counters.

Tell me which of the two you'd like next and I'll start that task (I'll create a todo and set it in-progress before editing files).

## Files added in this update
- `examples/atomics.asm` — atomic idioms and LR/SC example
- `examples/vector_dot.asm` — vector dot-product and vector add
- `examples/thread_pool.asm` — thread creation + message passing pattern
- `examples/dma_blit.asm` — DMA/blit usage with status polling
- `examples/memory_barrier.asm` — MBAR ordering examples
- `examples/hash_example.asm` — HASH.ACC / HASH.FINAL usage
- `benchmarks/README.md` — minimal benchmark protocol and recommended fields
- `benchmarks/validate.sh` — basic JSON validator for benchmark outputs