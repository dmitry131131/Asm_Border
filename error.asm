; Print error message
; Destroy               AH, DX
Print_error_message:
    mov ah, 09h                         ; Print error message
    mov dx, offset Error_message
    int 21h

    jmp Exit_programm                   ; jump to end of programm