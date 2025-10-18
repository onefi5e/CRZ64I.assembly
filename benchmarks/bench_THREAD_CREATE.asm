; BENCH_THREAD_CREATE
; op_NAME: THREAD_CREATE tid, func, stack

LOAD r0, #thread_func
LOAD r1, #stack

RDT r10
RTIME r20

THREAD_CREATE r2, r0, r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"THREAD_CREATE"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13