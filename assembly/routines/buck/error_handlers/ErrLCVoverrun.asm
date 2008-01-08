
  
;===============================================================================
; ErrLCVoverrun -- jumped to or called (currently by Price2)
;                   if the LCV array has been overrun
;  total: 61b
;  tested: yes
;===============================================================================
ErrLCVoverrun_text: .db "Algorithm Error:     LCV overrun",0 
ErrLCVoverrun: ;print error message and exit program
    ;print error message to screen
    call _clrScrn
    call _homeup
    ld hl,ErrLCVoverrun_text
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
    
