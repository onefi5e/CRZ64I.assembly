; BENCH_MSG_SEND
; op_NAME: MSG_SEND dst_tid, src, len

LOAD r0, #1
LOAD r1, #msg_buf
LOAD r2, #4

RDT r10
RTIME r20

MSG_SEND r0, r1, r2

RDT r11
RTIME r21

SUB r12, r11, r10
SUB r13, r21, r20
MOVE r30, #2
DIV r14, r12, r30

STORE [result+0], #"MSG_SEND"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
