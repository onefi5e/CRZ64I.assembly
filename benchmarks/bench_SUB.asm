; BENCH_SUB
; op_NAME: SUB r, a, b

LOAD r0, #10
LOAD r1, #3

RDT r10
RTIME r20

SUB r2, r0, r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"SUB"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13