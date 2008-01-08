

;==============================================================================
; clearmenumessage -- clears the message field in the menu (elements 2-4)
;  input: none
;  output: menu message area cleared
;  affects: assume everything
;  total: 36b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
    jp clearmenumessage         ;just in case!
clearmenumessage_row:
    .db %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
    .db %00000000,%00000000,%00000000
clearmenumessage:       ;writes over everything there
                        ;no need to _clrLCD
    ld de,$ff8d         ;where to start
    ld b,8
clearmenumessage_loop:
        push bc
    ld b,6
clearmenumessage_loop2:
    inc de
    djnz clearmenumessage_loop2
    ld hl,clearmenumessage_row     ;predone row of bytes
    ld bc,$0a           ;one row
    ldir
        pop bc
    djnz clearmenumessage_loop
    ret

