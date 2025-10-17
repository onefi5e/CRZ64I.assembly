; examples/vector_dot.asm
; Dot-product kernel using VDOT32 and VLOAD/VSTORE
; r0 = a_ptr, r1 = b_ptr, r2 = out_ptr

VLOAD v1, [r0]       ; load 4x32 from a
VLOAD v2, [r1]       ; load 4x32 from b
VDOT32 v0, v1, v2    ; v0 = sum(a[i]*b[i])
VSTORE [r2], v0      ; store result

; Vector add with constant
; vconst is Pre-loaded constant vector
VLOAD v1, [r0]
VADD.128 v2, v1, vconst
VSTORE [r2], v2
