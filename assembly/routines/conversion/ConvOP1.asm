
    
;============================================================
; ConvOP1 -- This is a special routine to replace the builtin calculator 
;         function _convOP1. It converts whatever is in OP1 from BCD to
;         HEX and places the result in DE. OP1 is assumed positive 
;         (ie: the result is always absolute value). No typechecking is done.
;  input:  OP1 = BCD floating-point number
;  output:  DE = converted number in hex (abolute value)
;  affects: A  = $fc
;           BC = DE
;           HL = _op1Location+2
;  total: 112b/488t (minimum, including ret, not including func. calls)
;  tested: yes
;  NOTES: The builtin function can process numbers only as large as 9999. 
;       I need a function that can process numbers at least as big as 
;       50000 and possibly on rare occasions larger. This function can
;       handle the full potential capacity of its two-byte output.
;       - The builtin function destroys OP1, this one preserves OP1.
;============================================================
ConvOP1:
    ld a,$fc            ;check for whole number
    ld hl,_op1Location+2
    cp (hl)
    jp z,ConvOP1_wholenum
    ld de,0
    ret                 ;no whole number; exit returning zero
ConvOP1_wholenum:
    ld a,4
    ld hl,_op1Location+1
    cp (hl)
    jp z,ConvOP1_sizechk
    jp nc,ConvOP1_convert
    jp ErrConvOP        ;number in OP1 is too big or a fraction
ConvOP1_sizechk:        ;max size is 65535 of course (two bytes)
    ld hl,_op1Location+3
    ld a,$65
    cp (hl)
    jp c,ErrConvOP      ;number in OP1 is too big
    jp nz,ConvOP1_convert       ;number in OP1 is okay to operate on
    inc hl
    ld a,$53
    cp (hl)
    jp c,ErrConvOP      ;number in OP1 is too big
    jp nz,ConvOP1_convert       ;number in OP1 is okay to operate on
    inc hl
    ld a,$59
    cp (hl)
    jp c,ErrConvOP      ;number in OP1 is too big
    ;continue           ;number in OP1 is okay to operate on
ConvOP1_convert:
    ld bc,ConvBlock_ConvOP1_multipliers  ;for later
    push bc
    ld bc,0             ;for later (total sum variable)
    ld a,(_op1Location+1)
    ld hl,_op1Location+3 ;store first number byte of op1 (for later)
    rra                 ;check radix location (between nibbles or bytes?)
    ld e,a              ;for later
    ld d,0              ;for later
    jp c,ConvOP1_nml_case
ConvOP1_spcl_case:         ;between nibbles
    add hl,de           ;get initial offset (start at least significant digit)
    pop de              ;multiplier address
    jp ConvOP1_MSN
ConvOP1_nml_case:          ;between bytes (normal case)
    add hl,de           ;get initial offset (start at least significant digit)
    pop de              ;multiplier address
ConvOP1_loop:
ConvOP1_LSN:                    ;(Least Significant Nibble)
    ld a,(hl)           ;A <- current byte to convert
    and $0F             ;mask out upper nibble (we only want the lower nibble for now)
    call ConvBlock    
ConvOP1_MSN:                    ;(Most Significant Nibble)
    ld a,(hl);           ;A <- current byte to convert
    sra a               ;shift upper nibble down to work with
    sra a               ; (this occasionally loads the vacated bytes with 1's
    sra a               ;  rather than zeros...  hence the mask following)
    sra a
    and $0F             ;mask out upper nibble (we only want the lower nibble)
    call ConvBlock
    ld a,$fc
    dec hl
    cp (hl)
    jp nz,ConvOP1_loop
    ld d,b
    ld e,c
    ret



;============================================================
; ConvBlock -- Takes a BCD byte with a zeroed  
;         most-significant-nibble, multiplies the
;         byte by its assigned place-value, and adds the 
;         result to whatever the current standing sum is
;         in the BCD-to-hex conversion process.
;           It assumes that the place-value multipliers are
;         consecutive within an array (in order to save time).
;  input: A  = BCD byte
;         DE = address of multiplier (multiplier is a 2-byte 
;                         place value, eg: 1,10,100,1000,...)
;         BC = the current standing sum
;  output: BC = total sum
;          DE = updated (twice incremented) multiplier address
;  affects: A -> destroyed
;  total: 29b/143t (minimum, including ret, not including func. calls)
;  tested: yes
;============================================================  
    jp ConvBlock_ConvOP1_multipliers+10
ConvBlock_ConvOP1_multipliers: .db $00,$01   ;1   (not little endian here!!!)
                  .db $00,$0a   ;10
                  .db $00,$64   ;100
                  .db $03,$e8   ;1000
                  .db $27,$10   ;10000
ConvBlock:   
    push hl             
    ld h,d              ;prep for Mult8~16Bit
    ld l,e
    ld d,(hl)
    inc hl
    ld e,(hl)
    inc hl              ;(multiplier must be a 2-byte value)
    push hl             ;multiplier address
    push bc             ;total sum
    call Mult8~16Bit
    pop bc              ;total sum
    add hl,bc
    ld c,l
    ld b,h
    pop de              ;multiplier address
    pop hl              
    ret
    


;============================================================
; ErrConvOP -- called by ConvOP1 if the intput is too big or
;                   a fraction, halts execution
;  total: 81b
;  tested: yes
;============================================================
errconvop_text: .db "Error: CONVOP1 input is too big or a fraction.",0
ErrConvOP: 
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    ld hl,errconvop_text
    call _puts
    ld hl,4
    ld (_curRow),hl
#ifdef DEBUG
    call _getkey
    call VarDump ;BLAMMO!!!
#endif
    call _dispDone
    call _jforcecmdnochar ;<-- this is a simple way to exit the program
    ret         
    
