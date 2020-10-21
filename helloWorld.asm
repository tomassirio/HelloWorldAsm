section .data
msg: DB 'Hello World!', 10
msgSize EQU $ - msg

global start

section .text

    start:
    mov rax, 0x2000004          ; function 4
    mov rbx, 1          ; stdout
    mov rcx, msg        ; msg
    mov rdx, msgSize    ; size
    int 0x80
    mov rax, 1          ; function 1
    mov rbx, 0          ; code
    int 0x80
    ret
