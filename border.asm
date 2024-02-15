model tiny
.386
.code 
org 100h
locals @@

White_back_black_front equ 70h
Black_back_white_front equ 07h

Start:
jmp main                ; jump to the main function

; The main function
main                proc

    mov bx, 0b800h          ; Puts to es offset to a vmem adress
    mov es, bx

    call Parser             ; Parse data from command line

    @@Main_loop:

    call Clear              ; Clear monitor

    call DisplayBorder      ; Display border

    call Check_input        ; Check input(pressed keys)

    call Clear              ; Clear monitor

    jmp @@Main_loop

;---------------------------------------------------------------
Exit_programm:
    mov ax, 4c00h           ; Terminate programm
    int 21h 
                    endp

; Function that clean monitor
; Destroy           AH, DX
Clear               proc
    mov ah, 09h
    mov dx, offset Clean_monitor
    int 21h

    ret
                    endp
;---------------------------------------------------------------
include data.asm
;---------------------------------------------------------------
include input.asm
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
    @@next:
        mov al, byte ptr [di]
        mov es:[si], ax
        add si, 2d
        inc di
    loop @@next

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
    @@next:
        mov es:[bx], ax
        add bx, 2d
    loop @@next
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
    mov cl, Border_height       ; get border height

    mov ax, 25d                 ; 25 - border height
    sub ax, cx

    shr ax, 1                   ; ax/2
    mov bx, 160d                

    mul bx                      ; ax * 160

    mov bx, ax                  ; get start position

;------------------------------------------------------
;get position by OX
    xor cx, cx
    mov cl, Border_width        ; get border width in cl

    mov ax, 80d                 ; 80 - Border_width
    sub ax, cx
;-------
    push bx                     ; save bx

    mov bx, ax                  ; this part for aligment by even numbers adress
    and bx, 1
    add ax, bx

    pop bx                      ; repair bx
;--------
    add bx, ax
    sub bx, 2d

    mov si, bx          ; get center of border
    xor ax, ax
    mov al, Border_width
    add si, ax

;------------------------------------------------

    call Select_mode                    ; set border style

    mov ah, White_back_black_front      ; Write first line
    call Write_line
    push di

    mov di, offset Hello_word           ; write border name
    call Write_String
    pop di

    mov dl, Border_height               ; write border body

    xor cx, cx
    mov cl, Text_position
    mov si, cx

    @@next:
        dec dl

        call Shift_to_next_line
        mov cl, Border_width

;-------------------------------------------------------------
        mov ah, Border_height           ; Select line color
        sub ah, dl
        cmp ah, Current_line
        je set_current_color
        mov ah, White_back_black_front
        Return_to_loop:
;-------------------------------------------------------------

        call Write_line

        mov al, Border_height           ; get current line number
        sub al, dl

        cmp al, Line_count
        ja @@Skip_text_line

        @@skip_next:
        inc si
        cmp [si], byte ptr ' '
        je @@skip_next

        push bx                         ; Save bx

        xor cx, cx
        mov cl, Border_width            ; get write position
        sub bx, cx
        sub bx, cx

        call Write_text_line_into_box

        pop bx                          ; Repair bx
        @@Skip_text_line:

        sub di, 3d

    cmp dl, 0
    jne @@next

    call Shift_to_next_line
    add di, 3d
                                     
    mov ah, White_back_black_front      ; write last line
    mov cl, Border_width
    call Write_line

    ret
                    endp

; Function set Black background and white text
; Destroy           AH
set_current_color:  
    mov ah, Black_back_white_front
    jmp Return_to_loop


; Select border mode by code
; Destroy           AH
; Return            DI - the position of the first symbol of selected border
Select_mode         proc
    mov ah, [Border_mode]

    cmp ah, 1d
        je @First_mode
    cmp ah, 2d
        je @Second_mode
    cmp ah, 3d
        je @Third_mode


    mov di, offset Border_1
    ret
    @First_mode:
        mov di, offset Border_1
        ret
    @Second_mode:
        mov di, offset Border_2
        ret
    @Third_mode:
        mov di, offset Border_3
        ret

                    endp

; Write text from input
; Entry             BX - position
; Asumes            ES = 0b800h
; Destroy           SI
Write_text_line_into_box proc

    @@next:
    cmp [si], byte ptr '$'               ; Check line terminator
    je @@end_loop

    mov al, byte ptr [si]
    mov es:[bx], ax

    add bx, 2d

    inc si

    jmp @@next

    @@end_loop:
    
    ret
                    endp

end Start