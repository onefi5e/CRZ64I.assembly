; BENCH_VLOAD
; op_NAME: VLOAD vdst, [addr]

VLOAD v0, [vec_a]

RDT r10
RTIME r20

VLOAD v1, [vec_b]

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"VLOAD"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13