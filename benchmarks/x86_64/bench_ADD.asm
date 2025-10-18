; CRZ64I to x86_64 mapped benchmark for ADD instruction
section .data
    result_cycles    dq 0
    result_latency  dq 0
    result_duration dq 0
    test_value1     dq 1234
    test_value2     dq 5678

section .text
global _start

_start:
    ; Prepare test values
    mov rax, [test_value1]
    mov rbx, [test_value2]
    
    ; Get start time (RDTSC)
    rdtsc
    shl rdx, 32
    or rax, rdx
    push rax        ; Save start time
    
    ; Execute ADD operation 1000 times for accurate measurement
    mov rcx, 1000
.loop:
    ; Equivalent of CRZ64I ADD
    add rax, rbx
    dec rcx
    jnz .loop
    
    ; Get end time
    rdtsc
    shl rdx, 32
    or rax, rdx
    
    ; Calculate cycles
    pop rbx         ; Get start time
    sub rax, rbx    ; cycles = end - start
    mov [result_cycles], rax
    
    ; Calculate latency (cycles / frequency)
    ; Assuming 3.4GHz for Core i3
    mov rbx, 3400000000
    div rbx
    mov [result_latency], rax
    
    ; Get duration using RDTSCP (more precise)
    rdtscp
    shl rdx, 32
    or rax, rdx
    mov [result_duration], rax
    
    ; Exit
    mov rax, 60    ; sys_exit
    xor rdi, rdi   ; return 0
    syscall