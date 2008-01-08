

;==============================================================================
; menu -- draws a menu at the bottom of the screen 
;  input: HL = pointer to menu data
;  output: menu drawn at bottom of screen
;  affects: Assume everything
;  total: 63b (excluding called functions, including ret)
;  tested: yes
;   NOTE -- 
;       menu data format: 
;           {byte -- column number},{byte -- display or not?},
;               {byte -- length of text string},{text string}
;==============================================================================
    jp menu         ;just in case!
menu_row:
    .db %11111111,%11111111,%11111111,%01111111,%11111111,%11111111,%10111111
    .db %11111111,%11111111,%11101111,%11111111,%11111111,%11111110,%11111111
    .db %11111111,%11111111
menu_data_example:  
        .db 3,1,4,"EXIT"
        .db 28,1,5,"ABOUT"
        .db 51,1,5,"SETUP"
        .db 77,0,1,"j"
        .db 103,1,4,"BUCK"

menu:                  ;writes over everything there
        push hl         ;save the start of the menu text to print
                        ;no need to _clrLCD
    ld de,$ff90         ;where to start
    ld b,8
menu_loop:
        push bc
    ld hl,menu_row          ;predone row of bytes
    ld bc,$10           ;one row
    ldir
        pop bc
    djnz menu_loop

    set textinverse,(iy+textflags)  ;write text on black background
        pop hl          ;get back the saved address of the text to print
    ld b,5              ;display 5 menu strings
    jp menu_text_loop
menu_text_nodisplay:
    inc b
menu_text_nodisplay_loop:
    inc hl
    djnz menu_text_nodisplay_loop
    pop bc
    dec b
    jp z,menu_end
menu_text_loop:
    push bc
    ld d,57                 ;text row on which to display
    ld e,(hl)               ;text column on which to display
    inc hl
    ld a,(hl)           ;is this element marked for display?
    inc hl
    ld b,(hl)           ;load B with size of text string
    cp 0
    jp z,menu_text_nodisplay
    inc hl
    ld (_penCol),de
    call _vputsn      
    pop bc
    djnz menu_text_loop
menu_end:
    res textinverse,(iy+textflags)  ;normal black text on white background
    ret

