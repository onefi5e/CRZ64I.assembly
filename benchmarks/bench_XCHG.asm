; BENCH_XCHG
; op_NAME: XCHG [addr], reg
; Outputs (to read from registers after run):
;   r12 = cycles_per_op
;   r14 = latency_ns
;   r13 = duration_ns

; initialize operands
LOAD r0, #ADDR    ; address
LOAD r1, #555     ; value

RDT r10
RTIME r20

XCHG [r0], r1

RDT r11
RTIME r21

SUB r12, r11, r10    ; cycles_per_op
SUB r13, r21, r20    ; duration_ns
MOVE r30, #2         ; FREQ_GHZ = 2 (replace with actual if available)
DIV r14, r12, r30    ; latency_ns = cycles_per_op / FREQ_GHZ

STORE [result+0], #"XCHG"
STORE [result+1], r12
STORE [result+2], r14
STORE [result+3], r13
