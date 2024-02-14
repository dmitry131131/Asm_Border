.data
    Border_1:  db 0c9h, 0cdh, 0bbh, 0bah, 0b0h, 0bah, 0c8h, 0cdh, 0bch, '$'
    Border_2:  db "/-\| |\-/", '$'
    Border_3:  db "+-+| |+-+" 
    Hello_word db 6d,"Hello!", '$'

    Border_width  db 10d
    Border_height db 10d
    Border_mode   db 01d

    Error_message db "Error!", '$'
.code