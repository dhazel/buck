

;==============================================================================
; clearmenu -- clears the menu 
;  input: none
;  output: menu area cleared
;  affects: assume everything
;  total: 16b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
clearmenu:
    ld hl,_winTop
    ld a,(hl)
    push af         ;save initial setting
    ld (hl),7
    call _clrWindow
    ld hl,_winTop
    pop af          ;restore initial setting
    ld (hl),a
    ret

