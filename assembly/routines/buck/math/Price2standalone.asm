

;============================================================
; Price2standalone -- calculates the price of a given log without including the
;           price-factor (skews log value for the volume-constraint framework)
;  input:   C   = length of log (in feet)
;           OP1 = volume of log 
;           B = index of current LCV element
;  output:  DE  = (price * 10)
;  affects: assume everything
;  total: 35b/169t (excluding func calls, including ret)
;  tested: no
;============================================================
    jp Price2standalone ;just in case!
Price2standalone_index: .db 0
Price2standalone:
    push bc

    ;set OP4 to 1 (this is the price-factor used by Price2, nullify its effects)
    call _op4set1

    ;load the LCV index for Price2
    pop bc                          ;B <- LCV index, C <- log length
    ld ix,Price2standalone_index
    ld (ix),b

    ;calculate price
    call Price2

    ;return
    ret

