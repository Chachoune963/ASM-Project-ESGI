extern printf

global main

%DEFINE NUM_POINTS 7
%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
printx: db "x : %d", 10, 0
printy: db "y : %d", 10, 0
jpp: db "On test le point: %d...", 10, 0
jenaismarre: db "Au PV de %d...", 10, 0
tuezmoi: db "Depuis le point %d", 10, 0
env: db "Enveloppe: %d", 10, 0
coef: db "Coef: %d", 10, 0
resultat: db "Resultat: %d", 10, 0

section .bss
coordx: resw NUM_POINTS
coordy: resw NUM_POINTS
enveloppe: resw NUM_POINTS
sizeEnveloppe: resb 1
randnum: resw 1
minpoint: resw 1
pv: resd 1

bestcandidate: resw 1

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
    
mov rbx, 0
printloop:
    mov rdi, printx
    movzx rsi, word[coordx+rbx*2]
    mov rax, 0
    call printf
    
    mov rdi, printy
    movzx rsi, word[coordy+rbx*2]
    mov rax, 0
    call printf
    
    inc rbx
    cmp rbx, NUM_POINTS
    jb printloop
        
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
xor rax, rax
xor rbx, rbx
xor rcx, rcx
mov ax, word[minpoint]
jarvis:
    mov [enveloppe+rbx*2], ax
    
    mov cx, ax
    inc cx
    cmp cx, NUM_POINTS
    jb nofix
    
    sub cx, NUM_POINTS
    
    nofix:
    push rbx
    xor rbx, rbx
    parcoursListe:
        mov r9w, word[coordy+rbx*2]
        sub r9w, word[coordy+rax*2]
        
        mov r10w, word[coordx+rcx*2]
        sub r10w, word[coordx+rbx*2]
        
        mov rdi, coef
        movsx rsi, r9w
        push rax
        push rbx
        push rcx
        mov rax, 0
        call printf
        pop rcx
        pop rbx
        pop rax
        
        imul r9w, r10w
        
        mov rdi, coef
        movsx rsi, r10w
        push rax
        push rbx
        push rcx
        mov rax, 0
        call printf
        pop rcx
        pop rbx
        pop rax
        
        mov rdi, resultat
        mov esi, r9d
        push rax
        push rbx
        push rcx
        mov rax, 0
        call printf
        pop rcx
        pop rbx
        pop rax
        
        
        mov r11w, word[coordx+rbx*2]
        sub r11w, word[coordx+rax*2]
        
        mov r12w, word[coordy+rcx*2]
        mov r12w, word[coordy+rbx*2]
        
        imul r11w, r12w
        
        sub r9d, r11d
        mov dword[pv], r9d
                
;        mov rdi, jpp
;        mov rsi, rbx
;        push rax
;        push rbx
;        push rcx
;        mov rax, 0
;        call printf
;        pop rcx
;        pop rbx
;        pop rax
;        
;        mov rdi, jenaismarre
;        mov esi, dword[pv]
;        push rax
;        push rbx
;        push rcx
;        mov rax, 0
;        call printf
;        pop rcx
;        pop rbx
;        pop rax
;        
;        mov rdi, tuezmoi
;        mov rsi, rcx
;        push rax
;        push rbx
;        push rcx
;        mov rax, 0
;        call printf
;        pop rcx
;        pop rbx
;        pop rax
        
        cmp dword[pv], 0
        jle nocandid
        
        mov rcx, rbx
        
        nocandid:
        inc rbx
        cmp rbx, NUM_POINTS
        jb parcoursListe
    pop rbx
    
    mov rax, rcx
    inc rbx
    cmp rbx, NUM_POINTS
    jae STOP
    cmp ax, word[minpoint]
    jne jarvis
STOP:        

; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret
