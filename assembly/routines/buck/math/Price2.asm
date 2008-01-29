

;============================================================
; Price2 -- calculates the price of a given log
;  input:   C   = length of log (in feet)
;           OP1 = volume of log 
;           OP4 = volume constraint price multiplication factor
;           LCV_size = size (from zero) of the LCV array
;           IX = pointer to index number of current LCV element
;           prices = array of corresponding prices 
;                   per thousand board-feet (mbf)
;  output:  DE  = (price * 10)
;  affects: assume everything
;           * does not affect IX
;  total: 44b/239t (excluding func calls, including ret)
;  tested: no
;============================================================
Price2:
    ;[c == length; op1 == volume]
                    ;#This function is a simple log price checker
                    ;
           ;[op1 = (volume/100)]
    ld hl,_op1Location+2
    ld d,(hl)
    dec hl
    ld e,(hl)
    dec de
    dec de
    ld (hl),e
    inc hl
    ld (hl),d
                    ;
    ;[check for LCV overrun]
    ld a,(LCV_size)
    cp (ix)
    jp c,ErrLCVoverrun

    ;[load B with current LCV index]
    ld b,(ix)   

    ;[use the index to associatively access log price]
    ld hl,prices
    call ArryAccessW_ne

    ;[determine log value]
    ld d,(hl)
    inc hl
    ld e,(hl)
    ld h,e ;[<-- depending on how the 'price' vectors are loaded this]
    ld l,d ;[<--    may need to be switched around (little endian)   ]
    call _setXXXXop2;            price = (Volume/1000) * price 
    call _FPMULT

    ;[check for volume constraint]
    ld b,(ix)
    ld hl,vol_constrain
    call ArrayAccess_ne
    ld a,0
    cp (hl)
    jp z,Price2_endPrice

    ;[multiply by the volume constraint factor]
    call _ex_op2_op4
    call _FPMULT
    call _ex_op2_op4

Price2_endPrice:    ;    return price
    call ConvOP1
                    ;
    ;[de == (price * 10)]
    ;[B is not still s]
    ret             ;return

