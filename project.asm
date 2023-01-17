extern printf

global main

%DEFINE NUM_POINTS 10
%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
fmt_printf: db "%d", 10, 0
fmt_index: db "vs: %d", 10, 0
fmt_min: db "Minimum: %d", 10, 0

section .bss
coordx: resw NUM_POINTS
coordy: resw NUM_POINTS
enveloppe: resw NUM_POINTS
sizeEnveloppe: resb 1
randnum: resw 1
minpoint: resw 1

; Variables de l'algo, potentiellement à renommer
P: resw 1

section .text
main:
; Génération des points du programme
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
    
    mov rdi, fmt_printf
    movzx rsi, word[coordx+rbx*2]
    mov rax, 0
    call printf
    
    inc rbx
    cmp rbx, NUM_POINTS
    jb populatex

populatey:
    stc
    checkcf:
        rdrand ax
    jnc checkcf
    mov [randnum], ax
    mody:
        sub word[randnum], MAX_Y
        cmp word[randnum], MAX_Y
        jae mody
    mov ax, word[randnum]
    mov word[coordy+rbx*2], ax
    inc rbx
    cmp rbx, NUM_POINTS
    jb populatey
    
; Trouver le point le plus à gauche
mov rbx, 0
mov word[minpoint], bx
inc rbx
minAlgo:
    ; On récupère le point minimum actuel
    movzx rcx, word[minpoint]
    movzx rax, word[coordx+rcx*2]
    
    ; On le compare au point parcouru actuel
    cmp ax, word[coordx+rbx*2]
    jb lower
            
    ; Si minpoint > point actuel, on mets point actuel dans minpoint
    mov rax, rbx
    mov word[minpoint], ax

    lower:
    inc rbx
    cmp rbx, NUM_POINTS
    jb minAlgo

; Une fois cette étape fini, nous connaissons le point le plus à gauche.
; On commence donc la marche de Jarvis
mov rbx, 0
jarvis:
    


; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret
