; examples/hash_example.asm
; Incremental hash using HASH.ACC and HASH.FINAL
; r0 = src_ptr, r1 = len, r2 = ctx_ptr, r3 = out_ptr

HASH.ACC r2, r0, r1, alg=sha256
HASH.FINAL r3, r2
STORE [r3], r4 ; store digest (pseudo)
