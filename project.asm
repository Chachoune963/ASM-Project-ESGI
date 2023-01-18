; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XDrawPoint
extern XFillArc
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

%DEFINE NUM_POINTS 10
%DEFINE MAX_X 255
%DEFINE MAX_Y 255

section .data
event:		times	24 dq 0

x1:	dd	0
x2:	dd	0
y1:	dd	0
y2:	dd	0

fmt_printf: db "%d", 10, 0
fmt_index: db "vs: %d", 10, 0
fmt_min: db "Minimum: %d", 10, 0

section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

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
    
mov rbx, 0
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
    ;########
    mov rdi, fmt_printf
    movzx rsi, word[coordy+rbx*2]
    mov rax, 0
    call printf
    ;########
    
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
    
    xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0xFFFFFF	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin			; on saute au label 'dessin'

cmp dword[event],KeyPress        ; Si on appuie sur une touche
je closeDisplay		        ; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle
    
;#########################################
;#        DEBUT DE LA ZONE DE DESSIN     #
;#########################################
dessin:

    ; boucle dessin point
    
    mov rbx, 0  
    draw_point_loop:

        ;couleur du point 1
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0x000000	; Couleur noire
        call XSetForeground
        
        ; Dessin d'un point du point
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]	
        movzx rcx, word [coordx+rbx*2] ; coordonnée en x du point généré
        sub ecx,3		
        movzx r8, word [coordy+rbx*2] ; coordonnée en y du point généré
        sub r8,3
        mov r9,6
        mov rax,23040
        push rax
        push 0
        push r9
        call XFillArc

        ;++loopcounter
        inc rbx
        
        ;check if end loop
        cmp rbx, NUM_POINTS
        jb draw_point_loop
        
        
    ; boucle dessin ligne
    
    mov rbx, 0 
    mov rax, 0 
    draw_line_loop:

        ;couleur de la ligne 1
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0x000000	; Couleur du crayon ; noir
        call XSetForeground
        
        ; coordonnées de la ligne 1 (noire)
        movzx eax, word [coordx+rbx*2]
        mov dword[x1],eax
        mov eax, 0
        
        movzx eax, word [coordy+rbx*2]
        mov dword[y1],eax
        mov eax, 0
        
        inc rbx
           
        cmp rbx , NUM_POINTS
        je set_draw_last_point
        
        movzx eax, word [coordx+rbx*2]
        mov dword[x2], eax
        mov eax, 0
        
        movzx eax, word [coordy+rbx*2]
        mov dword[y2], eax
        mov eax, 0
        
        ; dessin de la ligne 1
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov ecx,dword[x1]	; coordonnée source en x
        mov r8d,dword[y1]	; coordonnée source en y
        mov r9d,dword[x2]	; coordonnée destination en x
        push qword[y2]		; coordonnée destination en y
        call XDrawLine
        
        ;check if end loop
        cmp rbx, NUM_POINTS
        jb draw_line_loop
        
        set_draw_last_point:
            mov rbx, 0
            movzx eax, word [coordx+rbx*2]
            mov dword[x2], eax
            mov eax, 0
            
            movzx eax, word [coordy+rbx*2]
            mov dword[y2], eax
            mov eax, 0
            
            ; dessin de la ligne 1
            mov rdi,qword[display_name]
            mov rsi,qword[window]
            mov rdx,qword[gc]
            mov ecx,dword[x1]	; coordonnée source en x
            mov r8d,dword[y1]	; coordonnée source en y
            mov r9d,dword[x2]	; coordonnée destination en x
            push qword[y2]	; coordonnée destination en y
            call XDrawLine
            ;jmp flush
            
color_point_in:
        ;mov rbx, (le point en question)
        mov rbx,2
        ;couleur du point 1
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0x00FF00	; Couleur vert
        call XSetForeground
        
        ; Dessin du point
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]	
        movzx rcx, word [coordx+rbx*2] ; x
        sub ecx,3		
        movzx r8, word [coordy+rbx*2] ; y
        sub r8,3
        mov r9,6
        mov rax,23040
        push rax
        push 0
        push r9
        call XFillArc
        ;jmp flush
        
color_point_out:
        ;mov rbx, (le point en question)
        mov rbx, 5
        ;couleur du point 1
        mov rdi,qword[display_name]
        mov rsi,qword[gc]
        mov edx,0xFF0000	; Couleur rouge
        call XSetForeground
        
        ; Dessin du point
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]	
        movzx rcx, word [coordx+rbx*2] ; x
        sub ecx,3		
        movzx r8, word [coordy+rbx*2] ; y
        sub r8,3
        mov r9,6
        mov rax,23040
        push rax
        push 0
        push r9
        call XFillArc
        jmp flush
; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
    mov rdi,qword[display_name]
    call XFlush
    jmp boucle
    mov rax,34
    syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rcx
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit	

; Une fois cette étape fini, nous connaissons le point le plus à gauche.
; On commence donc la marche de Jarvis
mov rbx, 0
jarvis:
    
; Pour fermer le programme proprement :
mov    rax, 60         
mov    rdi, 0
syscall

ret
