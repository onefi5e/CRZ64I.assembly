; BENCH_STOREP
; op_NAME: STOREP [addr], reg_pair

LOAD r0, #ADDR
LOAD r1, #0x1111
LOAD r2, #0x2222

RDT r10
RTIME r20

STOREP [r0], r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"STOREP"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13