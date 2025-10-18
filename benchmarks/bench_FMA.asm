; BENCH_FMA
; op_NAME: FMA dst, a, b, c

LOAD r0, #1
LOAD r1, #2
LOAD r2, #3

RDT r10
RTIME r20

FMA r3, r0, r1, r2

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"FMA"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13