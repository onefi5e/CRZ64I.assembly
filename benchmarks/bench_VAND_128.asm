; BENCH_VAND.128
; op_NAME: VAND.128 vdst, va, vb

VLOAD v0, [vec_a]
VLOAD v1, [vec_b]

RDT r10
RTIME r20

VAND.128 v2, v0, v1

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"VAND.128"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13