
  
;===============================================================================
; ErrLCVoverrun -- jumped to or called (currently by Price2)
;                   if the LCV array has been overrun
;  total: 61b
;  tested: no
;===============================================================================
ErrLCVoverrun_text: .db "Algorithm Error:     LCV overrun",0 
ErrLCVoverrun: ;print error message and exit program
    ;print error message to screen
    call _clrScrn
    call _homeup
    ld hl,ErrLCVoverrun_text
    call _puts
    call _newline
    ld l,(ix)       ;(ix) == it[s]
    ld h,0
    ld a,0
    call _dispAHL
#ifdef DEBUG
    call _getkey
    call VarDump ;BLAMMO!!!
#endif
    ;exit program
    call _dispDone
    call _jforcecmdnochar
    ret
    
