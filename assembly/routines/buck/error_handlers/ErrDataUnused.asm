
    
;============================================================
; ErrDataUnused -- called by any execution that determines that
;                   data is being unused when it rather should be
;  total: 99b
;  tested: yes
;============================================================
errDataUnused_text: .db "Detected unused data! Warning: TIBASIC      routines are         altered!",0 
ErrDataUnused: ;if this happens simply exit the program
    ;print error message to screen
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    ld hl,errDataUnused_text
    call _puts
    call _newline
    ;exit program
    call _dispDone
    call _jforcecmdnochar
    ret

