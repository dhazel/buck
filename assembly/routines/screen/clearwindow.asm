

;==============================================================================
; clearwindow -- clears the window, but not the menu 
;  input: none
;  output: window area cleared
;  affects: assume everything
;  total: 16b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
clearwindow:
    ld hl,_winBtm
    ld a,(hl)
    push af         ;save initial setting
    ld (hl),7
    call _clrWindow
    ld hl,_winBtm
    pop af
    ld (hl),a       ;restore initial setting
    ret

