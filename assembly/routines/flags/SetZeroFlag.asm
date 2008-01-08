

;============================================================
; SetZeroFlag -- sets the zero flag and returns
;  input:   none
;  output:  zero flag is set
;  affects: A <- B
;           C == F
;  total: 7b, 60t
;  tested: yes
;============================================================
SetZeroFlag:
    push af
    pop bc
    set zeroFlag,c
    push bc
    pop af
    ret

