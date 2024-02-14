model tiny
.186
.code 
org 100h

Black_back_white_front equ 70h

Start:
jmp main                ; jump to the main function

; The main function
main                proc

    mov bx, 0b800h          ; Puts to es offset to a vmem adress
    mov es, bx

    call Parser

    call DisplayBorder

;---------------------------------------------------------------
Exit_programm:
    mov ax, 4c00h           ; Terminate programm
    int 21h 
                    endp

;---------------------------------------------------------------
include data.asm
;---------------------------------------------------------------
include error.asm
;---------------------------------------------------------------
include parser.asm
;---------------------------------------------------------------

; Write text line to display
; Entry             AH - color atribute
;                   SI - offset of memory
;                   DI - pointer to string
; Assumes           ES = 0b800h
; Destr             SI, CX, DI, AX
Write_String        proc
    mov cl, [di]       ; get count of symbols        
    inc di
    push ax

    mov ax, si         ; check  
    and ax, 1
    
    add si, ax
    sub si, cx
    add si, 2d

    pop ax
    next_2:
        mov al, byte ptr [di]
        mov es:[si], ax
        add si, 2d
        inc di
    loop next_2

    ret
                    endp

; Write 3 special symbols
; Entry             AH - background color atribute
;                   DI - special line position
;                   CX - count of central symbols
;                   BX - offset of memory
; Assumes           ES = 0b800h
; Destr             AL, DI, CX
Write_line          proc
    mov al, byte ptr [di]               ; write first symbol
    mov es:[bx], ax
    add bx, 2d
    inc di

    mov al, byte ptr [di]               ; Write second N symbols of line
    next:
        mov es:[bx], ax
        add bx, 2d
    loop next
    inc di

    mov al, byte ptr [di]               ; write first symbol
    mov es:[bx], ax
    add bx, 2d
    inc di

    ret
                    endp

; Shift to the next line function
; Entry             BX - memory adress
; Destr             BX, AX
; Return            BX position of the next line
Shift_to_next_line  proc
    xor ax, ax
    mov al, Border_width
    sub bx, ax
    sub bx, ax
    sub bx, 4d
    add bx, 160d
    ret
                    endp

; Write border in the midle on the monitor
; Entry             CX - width of the border
;                   AH - height of the border
; Assumes           ES = 0b800h
; Destr             CX, AX, BX, SI, DI, DX
DisplayBorder       proc
    xor cx, cx
    mov cl, Border_width

    mov bx, (4*80)*2    ; get start position
    mov ax, 80d
    sub ax, cx

    push bx
    mov bx, ax
    and bx, 1
    add ax, bx
    pop bx

    add bx, ax

    mov si, bx          ; get center of border
    xor ax, ax
    mov al, Border_width
    add si, ax

;------------------------------------------------

                    ; set border style
    call Select_mode

    mov ah, Black_back_white_front      ; Write first line
    call Write_line
    push di

    mov di, offset Hello_word           ; write border name
    call Write_String
    pop di

    mov dl, Border_height

    next_3:
        dec dl
        call Shift_to_next_line
        mov cl, Border_width
        mov ah, Black_back_white_front
        call Write_line
        sub di, 3d

    cmp dl, 0
    jne next_3

    call Shift_to_next_line
    add di, 3d
                                     
    mov ah, Black_back_white_front    ; write last line
    mov cl, Border_width
    call Write_line

    ret
                    endp

; Select border mode by code
; Destroy           AH
; Return            DI - the position of the first symbol of selected border
Select_mode         proc
    mov ah, [Border_mode]

    cmp ah, 1d
        je @@First_mode
    cmp ah, 2d
        je @@Second_mode
    cmp ah, 3d
        je @@Third_mode


    mov di, offset Border_1
    ret
    @@First_mode:
        mov di, offset Border_1
        ret
    @@Second_mode:
        mov di, offset Border_2
        ret
    @@Third_mode:
        mov di, offset Border_3
        ret

                    endp

end Start