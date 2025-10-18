; BENCH_CMPXCHG_MEM_REG
; op_NAME: CMPXCHG_MEM_REG [addr], rex, rnew -> flag

LOAD r0, #ADDR
LOAD r1, #0
LOAD r2, #1

RDT r10
RTIME r20

CMPXCHG_MEM_REG [r0], r1, r2 -> r3

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"CMPXCHG_MEM_REG"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13