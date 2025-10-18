; BENCH_MOV
; op_NAME: MOV dst, src

LOAD r0, #42

RDT r10
RTIME r20

MOV r1, r0

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"MOV"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
