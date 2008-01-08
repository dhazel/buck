
   
;============================================================
; ErrTooLong -- called by any execution that determines that
;                   the tree is too long for the mill.
;                   As of this writing Buck calls this error.
;  total: 67b
;  tested: yes
;============================================================
errTooLong_text: .db "The tree is too long to safely calculate!",0 
ErrTooLong: ;if this happens simply exit the program
    ;print error message to screen
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    ld hl,errTooLong_text
    call _puts
    call _newline
#ifdef DEBUG
    call _getkey
    call VarDump ;BLAMMO!!!
#endif
    ;exit program
    call _dispDone
    call _jforcecmdnochar
    ret
    
