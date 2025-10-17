; examples/dma_blit.asm
; Using BLIT_START to move large buffers off-CPU
; r0 = src_addr, r1 = dst_addr, r2 = len

BLIT_START r0, r1, r2 -> h
; poll status until done
1: BLIT_STATUS h -> st
   CMP st, #0
   IF st != 0 GOTO 1
; continue once transfer complete

; Example: prefetch then DMA
PREF r0, hint=stream
BLIT_START r0, r1, r2 -> h
