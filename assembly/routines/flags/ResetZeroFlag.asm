

;============================================================
; ResetZeroFlag -- resets the zero flag and returns
;  input:   none
;  output:  zero flag is reset
;  affects: B <- A
;           C is destroyed
;  total: 7b, 60t
;  tested: yes
;============================================================
ResetZeroFlag:
    push af
    pop bc
    res zeroFlag,c
    push bc
    pop af
    ret

