extern printf

global main

%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
fmt_printf: db "Test: %d", 10, 0

section .bss
coordx: resw 10
coordy: resw 10
randnum: resw 1

section .text
main:
; insérez votre code ici

mov rbx, 0
populatex:
    rdrand ax
    mov [randnum], ax
    modx:
        sub word[randnum], MAX_X
        cmp word[randnum], MAX_X
        jae modx
    mov ax, word[randnum]
    mov word[coordx+rbx*2], ax
    inc rbx
    cmp rbx, 10
    jb populatex

populatey:
    rdrand ax
    mov [randnum], ax
    mody:
        sub word[randnum], MAX_Y
        cmp word[randnum], MAX_Y
        jae mody
    mov ax, word[randnum]
    mov word[coordy+rbx*2], ax
    inc rbx
    cmp rbx, 10
    jb populatey

; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret