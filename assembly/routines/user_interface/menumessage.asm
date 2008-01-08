

;==============================================================================
; menumessage -- prints a message in the menu message area
;  input: HL = pointer to the message text
;  output: menu message is printed
;  affects: assume everything
;  total: 18b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
menumessage:
    push hl

    ;clear the message field
    call clearmenumessage

    ;write the message
        ld a,30              
    ld (_penCol),a
        ld a,57
    ld (_penRow),a
    pop hl
    call _vputs    
    
    ret ;return

