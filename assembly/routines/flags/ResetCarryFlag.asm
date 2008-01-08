

;============================================================
; ResetCarryFlag -- resets the carry flag and returns
;  input:   none
;  output:  carry flag is reset
;  affects: A <- B
;           C == F
;  total: 7b, 60t
;  tested: yes
;============================================================
ResetCarryFlag:
    push af
    pop bc
    res carryFlag,c
    push bc
    pop af
    ret
    
