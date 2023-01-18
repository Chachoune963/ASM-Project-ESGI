extern printf

global orientation
orientation:
    ; Coord de P dans di et si
    ; Coord de I dans dx et cx
    ; Coord de Q dans r8w et r9w
    
    ; cx sera bientôt modifié mais on doit l'utiliser 2 fois
    ; Donc on le sauvegarde
    push cx
    sub cx, si
    sub r8w, dx
    
    imul cx, r8w
    
    ; Nous n'utiliserons plus si
    ; Donc nous restaurons la valeur de cx dans si
    pop si
    sub dx, di
    sub r9w, si
    
    imul dx, r9w
    
    sub cx, dx
    
    cmp ecx, 0
    jle clockwise
    
    mov eax, 1
    jmp endori
    
    clockwise:
    mov eax, 0
    
    endori:
ret

global main

%DEFINE NUM_POINTS 7
%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
test: db "Test", 10, 0
printx: db "x : %d", 10, 0
printy: db "y : %d", 10, 0
jpp: db "On test le point: %d...", 10, 0
jenaismarre: db "Au PV de %d...", 10, 0
tuezmoi: db "Depuis le point %d", 10, 0
env: db "Enveloppe: %d", 10, 0
coef: db "Coef: %d", 10, 0
resultat: db "Resultat: %d", 10, 0

coordx: dw 0, 2, 1, 2, 3, 0, 3
coordy: dw 0, 2, 1, 2, 3, 0, 3

section .bss
;coordx: resw NUM_POINTS
;coordy: resw NUM_POINTS
enveloppe: resw NUM_POINTS
sizeEnveloppe: resb 1
randnum: resw 1
minpoint: resw 1

P: resw 1
Q: resw 1
I: resw 1

section .text

main:
; Génération des points du programme
;mov rbx, 0
;populatex:
;    rdrand ax
;    mov [randnum], ax
;    modx:
;        sub word[randnum], MAX_X
;        cmp word[randnum], MAX_X
;        jae modx
;    mov ax, word[randnum]
;    mov word[coordx+rbx*2], ax
;    
;    inc rbx
;    cmp rbx, NUM_POINTS
;    jb populatex
;
;mov rbx, 0
;populatey:
;    rdrand ax
;    mov word[randnum], ax
;    mody:
;        sub word[randnum], MAX_Y
;        cmp word[randnum], MAX_Y
;        jae mody
;    mov ax, word[randnum]
;    mov word[coordy+rbx*2], ax
;
;    inc rbx
;    cmp rbx, NUM_POINTS
;    jb populatey
    
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
    jbe lower
            
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
mov ax, word[minpoint]
mov word[P], ax
mov word[sizeEnveloppe], 0
jarvis:
    mov ax, word[P]
    movzx rbx, word[sizeEnveloppe]
    mov [enveloppe+rbx*2], ax
    
    mov word[Q], ax
    inc word[Q]
    cmp word[Q], NUM_POINTS
    jb nofix
    
    sub word[Q], NUM_POINTS
    
    nofix:
    mov word[I], 0
    parcoursListe:
        ; Coord de P dans di et si
        movzx rax, word[P]
        mov di, word[coordx+rax*2]
        mov si, word[coordy+rax*2]
        
        ; Coord de I dans dx et cx
        movzx rax, word[I]
        mov dx, word[coordx+rax*2]
        mov cx, word[coordy+rax*2]
        
        ; Coord de Q dans r8w et r9w
        movzx rax, word[Q]
        mov r8w, word[coordx+rax*2]
        mov r9w, word[coordy+rax*2]
        mov rax, 0
        call orientation
        
        cmp eax, 0
        jle nocandid
        
        movzx rbx, word[I]
        mov word[Q], bx
        
        nocandid:
        
        inc word[I]
        cmp word[I], NUM_POINTS
        jb parcoursListe    
    mov bx, word[Q]
    mov word[P], bx
    inc word[sizeEnveloppe]
;    cmp word[sizeEnveloppe], NUM_POINTS
;    jae STOP
    mov bx, word[minpoint]
    cmp word[P], bx
    jne jarvis
;STOP:

mov rbx, 0
printenv:
    mov rdi, env
    movzx rsi, word[enveloppe+rbx*2]
    mov rax, 0
    call printf

    inc rbx
    cmp bx, word[sizeEnveloppe]
    jb printenv

; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret