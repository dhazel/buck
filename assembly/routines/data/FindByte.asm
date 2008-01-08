

;============================================================
; FindByte -- finds a specified byte value following a start 
;               address (returns the first match it finds)
;  input:   B == size of array to search (indexed from zero)
;           HL == start address (array to search)
;           A == value to find
;  output:  HL <- address of found byte
;           D <- array index (from zero) of found byte
;           zero flag set if byte not found, reset if found
;  affects: B <- destroyed
;           C <- destroyed
;           A <- destroyed
;  total: 23b
;  tested: yes 
;   NOTE: this may be further improved by updating the input and output
;           specification, which has been left unchanged from bc52 to simplify 
;           backwards compatibility (basically, because I'm lazy right now)
;============================================================
FindByte:
    ld c,b
    ld e,c              ;save array size for later
    inc c
    ld b,0
    cpir                ;search the array   (if we hit a match, bc decrements)
    dec hl              ;will have stepped past matching address
    cp (hl)
    jp z,FindByte_found
FindByte_notfound:
    ;set zero flag
    call SetZeroFlag
    ret
FindByte_found:
    ;load D with array index of matched element
    ld a,e              ;A <- size of array
    sub c               ;index = size - decremented value
    ld d,a

    ;reset zero flag
    call ResetZeroFlag
    ret

