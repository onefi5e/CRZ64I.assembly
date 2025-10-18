; BENCH_MSG_RECV
; op_NAME: MSG_RECV dst, src_tid

LOAD r0, #msg_buf

RDT r10
RTIME r20

MSG_RECV r0

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"MSG_RECV"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13