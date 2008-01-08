

;============================================================
; SetCarryFlag -- resets the carry flag and returns
;  input:   none
;  output:  carry flag is reset
;  affects: nothing
;  total: 2b, 14t
;  tested: yes
;============================================================
SetCarryFlag:
    scf     ;[this will set the carry flag]
    ret

