; examples/memory_barrier.asm
; Demonstrate MBAR usage for ordering across components
; r0 = addr1, r1 = addr2

; writer
STORE [r0], r2
MBAR FULL
STORE [r1], r3

; reader (guarantees seeing writer's store after MBAR)
LOAD r4, [r1]
MBAR FULL
LOAD r5, [r0]
