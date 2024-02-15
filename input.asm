; Function fetch keyboard input and do smth
; Destroy           AX
Check_input         proc

    mov ah, 01h             
    int 21h

    cmp al, 'q'
    je Exit_programm

    cmp al, 50h      ;   Down button
    je Inc_curr_line

    cmp al, 48h      ;   Up   button
    je Dec_curr_line

    ret

    Inc_curr_line:
        mov al, Current_line
        cmp al, Border_height
        je @@Return
        inc al
        mov Current_line, al
        ret
    Dec_curr_line:
        mov al, Current_line
        cmp al, 1d
        je @@Return

        dec al
        mov Current_line, al

        @@Return:
        ret

                    endp