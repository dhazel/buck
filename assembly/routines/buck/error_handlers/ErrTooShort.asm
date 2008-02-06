
     
;============================================================
; ErrTooShort -- called by any execution that determines that
;                   the tree is too short for the mill.
;                   As of this writing Buck calls this error.
;  total: 70b
;  tested: yes
;============================================================
errTooShort_text: .db "The tree is too short for the mill!",0 
ErrTooShort: ;if this happens simply exit the program
    ;turn off user system routines
    call UserSysRoutOff    ;NOTE: excludes the user-on routine

    ;print error message to screen
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    ld hl,errTooShort_text
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
    
