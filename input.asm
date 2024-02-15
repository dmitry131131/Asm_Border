; Function fetch keyboard input and do smth
; Destroy           AX
Check_input         proc

    mov ah, 01h             
    int 21h

    cmp al, 'q'
    je Exit_programm

    ret
                    endp