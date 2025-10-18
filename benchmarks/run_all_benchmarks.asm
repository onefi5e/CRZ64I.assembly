; CRZ64I Benchmark Test Framework
; Executes and validates all 65 benchmarks

.data
results_buffer:    .space 1024  ; Space for benchmark results
test_header:       .ascii "=== CRZ64I Benchmark Validation ==="
newline:           .ascii "\n"
executing_msg:     .ascii "Executing benchmark: "
pass_msg:         .ascii " ✓ PASS"
fail_msg:         .ascii " ✗ FAIL"
cycles_msg:       .ascii "Cycles: "
latency_msg:      .ascii "Latency: "
duration_msg:     .ascii "Duration: "
ns_suffix:        .ascii "ns"

.text
.global _start

_start:
    ; Initialize result buffer pointer
    LOAD r29, #results_buffer
    
    ; Print test header
    LOAD r0, #test_header
    SYS_CALL #PRINT_STRING
    LOAD r0, #newline
    SYS_CALL #PRINT_STRING

execute_benchmarks:
    ; Loop through all benchmark files
    LOAD r28, #benchmark_list  ; List of benchmark files to execute
    LOAD r27, #0              ; Counter for benchmarks

benchmark_loop:
    ; Load next benchmark path
    LOAD r0, [r28]
    CMP r0, #0
    JE done_benchmarks        ; If null, we're done
    
    ; Print executing message
    LOAD r0, #executing_msg
    SYS_CALL #PRINT_STRING
    LOAD r0, [r28]
    SYS_CALL #PRINT_STRING
    
    ; Execute benchmark 5 times and average results
    LOAD r26, #5             ; Number of iterations
    LOAD r25, #0            ; Sum of cycles
    LOAD r24, #0            ; Sum of latency
    LOAD r23, #0            ; Sum of duration

execute_iteration:
    ; Clear result buffer for this iteration
    STORE [r29+0], #0
    STORE [r29+4], #0
    STORE [r29+8], #0
    STORE [r29+12], #0
    
    ; Execute the benchmark
    CALL [r28]              ; Call the benchmark code
    
    ; Accumulate results
    LOAD r1, [r29+4]        ; cycles
    ADD r25, r25, r1
    LOAD r1, [r29+8]        ; latency
    ADD r24, r24, r1
    LOAD r1, [r29+12]       ; duration
    ADD r23, r23, r1
    
    ; Loop control
    DEC r26
    JNZ execute_iteration
    
    ; Calculate averages
    LOAD r1, #5
    DIV r25, r25, r1        ; Average cycles
    DIV r24, r24, r1        ; Average latency
    DIV r23, r23, r1        ; Average duration
    
    ; Validate results
    CALL validate_results
    
    ; Next benchmark
    ADD r28, r28, #4
    ADD r27, r27, #1
    JMP benchmark_loop

validate_results:
    ; Save return address
    STORE [sp-4], lr
    SUB sp, sp, #4
    
    ; 1. Check reasonable cycle count (1-1000)
    LOAD r1, r25            ; Load cycles
    CMP r1, #1
    JL validation_failed
    CMP r1, #1000
    JG validation_failed
    
    ; 2. Check latency calculation
    ; latency should be approximately cycles/freq
    LOAD r1, r25            ; Load cycles
    LOAD r2, #24            ; 2.4 GHz -> 24 for fixed point
    DIV r1, r1, r2         ; Expected latency
    LOAD r2, r24           ; Actual latency
    SUB r3, r2, r1         ; Difference
    ABS r3, r3
    CMP r3, r1             ; If diff > expected, fail
    JG validation_failed
    
    ; 3. Check duration >= latency
    LOAD r1, r24           ; Load latency
    LOAD r2, r23           ; Load duration
    CMP r2, r1
    JL validation_failed
    
    ; 4. Check duration not too high
    MUL r1, r1, #10
    CMP r2, r1
    JG validation_failed
    
    ; Print PASS
    LOAD r0, #pass_msg
    SYS_CALL #PRINT_STRING
    
    ; Print results
    CALL print_results
    
    JMP validation_done

validation_failed:
    LOAD r0, #fail_msg
    SYS_CALL #PRINT_STRING

validation_done:
    ; Restore return address
    LOAD lr, [sp]
    ADD sp, sp, #4
    RET

print_results:
    ; Print cycles
    LOAD r0, #cycles_msg
    SYS_CALL #PRINT_STRING
    LOAD r0, r25
    SYS_CALL #PRINT_NUM
    LOAD r0, #newline
    SYS_CALL #PRINT_STRING
    
    ; Print latency
    LOAD r0, #latency_msg
    SYS_CALL #PRINT_STRING
    LOAD r0, r24
    SYS_CALL #PRINT_NUM
    LOAD r0, #ns_suffix
    SYS_CALL #PRINT_STRING
    LOAD r0, #newline
    SYS_CALL #PRINT_STRING
    
    ; Print duration
    LOAD r0, #duration_msg
    SYS_CALL #PRINT_STRING
    LOAD r0, r23
    SYS_CALL #PRINT_NUM
    LOAD r0, #ns_suffix
    SYS_CALL #PRINT_STRING
    LOAD r0, #newline
    SYS_CALL #PRINT_STRING
    
    RET

done_benchmarks:
    ; Print summary
    LOAD r0, #newline
    SYS_CALL #PRINT_STRING
    LOAD r0, #summary_header
    SYS_CALL #PRINT_STRING
    LOAD r0, r27
    SYS_CALL #PRINT_NUM
    LOAD r0, #benchmarks_tested
    SYS_CALL #PRINT_STRING
    
    ; Exit program
    SYS_CALL #EXIT

.data
summary_header:    .ascii "\nBenchmark Summary\n"
benchmarks_tested: .ascii " benchmarks tested.\n"

; List of benchmark files to execute
benchmark_list:
    .word bench_ADD
    .word bench_SUB
    .word bench_AND
    .word bench_OR
    .word bench_XOR
    .word bench_NOT
    .word bench_SHL
    .word bench_SHR
    ; ... (continue for all 65 benchmarks)
    .word 0  ; null terminator