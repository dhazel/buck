

;============================================================
; UserSysRoutOff -- Turns off the user-interrupt and user-off routines, does not
;           include the user-on routine
;  input:   none
;  output:  turns system routines (user-interrupt and user-off) off
;  affects: assume everything
;  total: 9b
;  tested: yes
;============================================================
UserSysRoutOff:
    ;turn off user system routines, excluding the on routine
    res alt_off,(iy + exceptionflg)     ;user off routine
    res alt_int,(iy + exceptionflg)     ;user interrupt routine

    ;return
    ret
    
