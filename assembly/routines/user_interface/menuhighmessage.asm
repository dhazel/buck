

;==============================================================================
; menuhighmessage -- prints a message above the menu message area
;  input: HL = pointer to the message text
;  output: menu message is printed
;  affects: assume everything
;  total: 14b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
menuhighmessage:
        ld a,30 
    ld (_penCol),a
        ld a,49
    ld (_penRow),a
    call _vputs   
    ret

