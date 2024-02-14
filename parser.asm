; Parser functtion that puts data from command line to memory
; 
; Desrtoy           AX, BX, DI
Parser              proc
    mov di, 82h     ; set pointer in the start of command line
;------------------------------------------------------------------
; Get border width
    call Parse_number    

    mov [Border_width], byte ptr al
;------------------------------------------------------------------
; Get border height
    inc di          ; go to start of the first symbol

    call Parse_number                   

    mov [Border_height], byte ptr al
;------------------------------------------------------------------
; Get border style
    inc di

    call Parse_number

    mov [Border_mode], byte ptr al
    ret
                    endp


; Function that count symbols of word
; Entry             DI - start position
; 
; Destroy           DI
; Return            DI - position of end of word (the first ' ' after number)
Counter             proc

    @@start_counter_loop:
    cmp byte ptr [di], ' '
    je @@end_counter_loop
        inc di
    jmp @@start_counter_loop
    @@end_counter_loop:

    ret
                    endp

; Parse number - function that parse number and returns it to ax reguster
; Entry             DI - start of string with 
; Destroy           DI, AX, BX, CX
; Return            AL - the number
Parse_number       proc
    mov bx, di                  ; save start position in CX

    call Counter                ; set di in the end of nubmer

    sub di, bx                  ; get count of sumbols and write it in CX
    mov cx, di

    mov di, bx                  ; set di in the start of number
;--------------------------------------------------------------------------
    cmp cx, 3d                  ; check len of number
        jae Print_error_message
    cmp cx, 0d
        je  Print_error_message

    xor ax, ax                  ; set 0 in ax

    cmp cx, 2d
    jne @@Add_last_part

    mov al, byte ptr [di]       ; get first number code
    sub al, '0'                 ; get first number from code
    mov ah, 10d                 ; mul first number to 10 and save in in ah
    mul ah
    mov ah, al

    inc di                      ; go to next number

    @@Add_last_part:

    mov al, byte ptr [di]       ; get next number code
    sub al, '0'                 ; get real nubber from code

    add al, ah                  ; add first number with second one

    inc di                      ; go to the next symbol after number

    ret
                    endp