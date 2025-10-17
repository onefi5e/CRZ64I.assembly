; examples/thread_pool.asm
; Simple worker creation pattern and message passing
; main: create 4 workers to process chunks and send partial sums

; Pseudocode / example usage
; THREAD_CREATE tid, entry, stack
; Each worker: compute partial sum and MSG_SEND to aggregator

; create worker threads (pseudo registers)
LOAD r0, #worker_entry
LOAD r1, #stack_base
THREAD_CREATE t0, r0, r1
THREAD_CREATE t1, r0, r1
THREAD_CREATE t2, r0, r1
THREAD_CREATE t3, r0, r1

; aggregator waits for 4 messages
LOAD r2, #4
agg_loop:
MSG_RECV r3, handle
; process received partial sum in r3
DEC r2
IF r2 != 0 GOTO agg_loop

THREAD_JOIN t0
THREAD_JOIN t1
THREAD_JOIN t2
THREAD_JOIN t3
