; BENCH_XOR
; op_NAME: XOR r, a, b

LOAD r0, #0xF0F0
LOAD r1, #0x0F0F

RDT r10
RTIME r20

XOR r2, r0, r1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"XOR"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
