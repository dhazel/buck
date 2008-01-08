

;============================================================
; Price2standalone -- calculates the price of a given log
;           without requiring any index data
;  input:   C   = length of log (in feet)
;           OP1 = volume of log 
;           LCV_size = size (from zero) of the LCV array
;           prices = array of corresponding prices 
;                   per thousand board-feet (mbf)
;  output:  DE  = (price * 10)
;  affects: assume everything
;           * does not affect IX
;  total: 35b/169t (excluding func calls, including ret)
;  tested: yes
;============================================================
    jp Price2standalone ;just in case!
Price2standalone_index: .db 0
Price2standalone:
    ld a,(LCV_size)
    ld b,a
    ld hl,LCV
    ld a,c

    push bc
    call FindByte
    pop bc
    jp nz,Price2standalone_lengthexists
    ld de,0     ;return with price = 0 
    ret
Price2standalone_lengthexists:
    ld ix,Price2standalone_index
    ld (ix),d

    call Price2

    ret

