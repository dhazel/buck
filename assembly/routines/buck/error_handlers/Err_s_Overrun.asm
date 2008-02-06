
   
;============================================================
; Err_s_Overrun -- This is the most important error handler.
;                       It is called if the Buck algorithm 
;                       tries to execute beyond its bounds.
;  total: 175b
;  tested: yes
;============================================================
err_s_overrun_text: .db "FATAL ERROR:         S iterator overrun.  Please contact the     program author.    The error precedes     the following        address: ",0 
Err_s_Overrun: ;if this happens *BAD*, exit emediately
    ;This error handler assumes that the emmediate stack slot
    ;   holds an address near and following the offending 
    ;   location.
    ;
    ;turn off user system routines
    call UserSysRoutOff    ;NOTE: excludes the user-on routine

    ;print error message to screen
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    ld hl,err_s_overrun_text
    call _puts
    pop hl
    ld a,0
    call _dispAHL ;NOTE: this displays the given address in decimal, not hex!!
#ifdef DEBUG
    call _getkey
    call VarDump ;BLAMMO!!!
#endif
    ;exit program
    call _dispDone
    call _jforcecmdnochar
    ret

