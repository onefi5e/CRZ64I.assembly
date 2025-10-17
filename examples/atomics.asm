; examples/atomics.asm
; Small examples showing atomic idioms for CRZ64I

; Atomic increment loop (shared counter)
; r0 = &counter
1: LR [r0], r1           ; load-reserved value into r1
   ADD r2, r1, #1       ; r2 = r1 + 1
   SC [r0], r2 -> ok    ; try to store
   SEL r3, ok, #0, #1   ; if ok skip increment retry (branchless hint)
   IF !ok GOTO 1

; Atomic fetch-and-add (single instruction)
; r0 = &counter, r1 = delta
FADD.ATM [r0], r1 -> old

; Atomic compare-and-swap
; r0 = &slot, r1 = expected, r2 = new
CASX [r0], r1, r2 -> flag

; Atomic bitmap set (AND variant)
; r0 = &bitmap, r1 = mask
ANDB.ATM [r0], r1 -> old
