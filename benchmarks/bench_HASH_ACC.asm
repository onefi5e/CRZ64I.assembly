; BENCH_HASH.ACC
; op_NAME: HASH.ACC dst, src, len

LOAD r0, #hash_buf
LOAD r1, #len

RDT r10
RTIME r20

HASH.ACC r2, r0, r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"HASH.ACC"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
