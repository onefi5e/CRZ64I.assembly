; BENCH_AND
; op_NAME: AND r, a, b

LOAD r0, #0xFF
LOAD r1, #0x0F

RDT r10
RTIME r20

AND r2, r0, r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"AND"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
