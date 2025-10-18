; BENCH_SC
; op_NAME: SC [addr], reg -> flag

LOAD r0, #ADDR
LOAD r1, #1

RDT r10
RTIME r20

SC [r0], r1 -> r2

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"SC"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13