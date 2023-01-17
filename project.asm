extern printf

global main

%DEFINE NUM_POINTS 20
%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
pointcheck: db "Passage du point %d", 10, 0
fmt_printf_test: db "Test de %d", 10, 0
fmt_printf: db "Reussite: %d", 10, 0

section .bss
coordx: resw NUM_POINTS
coordy: resw NUM_POINTS
enveloppe: resw NUM_POINTS
sizeEnveloppe: resb 1
randnum: resw 1
minpoint: resw 1

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
    
    inc rbx
    cmp rbx, NUM_POINTS
    jb populatex

mov rbx, 0
populatey:
    rdrand ax
    mov word[randnum], ax
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
; Marche de Jarvis
; rax = Prochain point (P)
; rbx = Index actuel de enveloppe (Pas d'équivalent, à ne pas utiliser pr l'instant)
; rcx = Prochain candidat de P (Q)
movzx rax, word[minpoint]
mov rbx, 0
mov rcx, 0
jarvis:
    ; On mets le dernier resultat dans enveloppe
    mov word[enveloppe+rbx*2], ax
        
        push rax
        mov rdi, fmt_printf
        mov si, word[enveloppe+rbx*2]
        mov rax, 0
        call printf
        pop rax

    movzx rcx, ax
    
    push rbx
    ; rbx devient (I)
    mov rbx, 0
    parcoursPoints:
        
        push rax
        mov rdi, pointcheck
        movzx rsi, word[coordy+rbx*2]
        mov rax, 0
        call printf
        pop rax

        ; Calcul du produit vectoriel
        ; r8w = xP
        mov r8w, word[coordx+rax*2]
        ; r9w = yP
        mov r9w, word[coordy+rax*2]
        ; r10w = xI
        mov r10w, word[coordx+rbx*2]
        ; r11w = yI
        mov r11w, word[coordy+rbx*2]
        ; r10 = r10 - r8 = xPI
        sub r10w, r8w
        ; r11 = r11 - r9 = yPI
        sub r11w, r9w
        ; r8w = xI
        mov r8w, word[coordx+rbx*2]
        ; r9w = yI
        mov r9w, word[coordy+rbx*2]
        ; r12 = xQ
        mov r12w, word[coordx+rcx*2]
        ; r13 = yQ
        mov r13w, word[coordy+rcx*2]
        ; r12 = r12 - r8 = xIQ
        sub r12w, r8w
        ; r13 = r13 - r9 = yIQ
        sub r13w, r9w
        ; xIQ * yPI = r12 * r11
        imul r12w, r11w
        ; xPI * yIQ = r10 * r13
        imul r10w, r13w
        ; Produit vectoriel => r12
        sub r12d, r10d
        cmp r12d, 0
        jl notcandidate
        
        push rax
        mov rdi, fmt_printf_test
        mov dword[rsi], r12d
        mov rax, 0
        call printf
        pop rax
        
        
        mov rcx, rbx
        
        push rax
        mov rdi, fmt_printf
        mov rsi, rcx
        mov rax, 0
        call printf
        pop rax
        
        notcandidate:
        inc rbx
        
        cmp rbx, NUM_POINTS
        jb parcoursPoints
    ; rbx redevient l'index actuel de l'enveloppe)
    pop rbx
    inc rbx
    mov rax, rcx    
    
    cmp ax, word[enveloppe]
    jne jarvis

; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret
