; BENCH_MMIO_READ
; op_NAME: MMIO_READ dst, addr

LOAD r0, #MMIO_ADDR

RDT r10
RTIME r20

MMIO_READ r1, r0

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"MMIO_READ"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13