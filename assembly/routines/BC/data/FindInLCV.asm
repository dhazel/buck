

;============================================================
; FindInLCV -- finds an LCV entry matching the input request, checks criteria
;               as well
;  input:   HL == start address of the "result" data structure (see Bcalculate)
;           B == index of length/diameter pair to find (from zero)
;  output:  B <- array index (from zero) of found LCV element
;           E <- length
;           D <- diameter
;           zero flag set if byte not found, reset if found
;  affects: TBA
;  total: 71b
;  tested: yes 
;============================================================
FindInLCV:
    ;extract length and diameter to search for
    push hl
    call ArrayAccess
    ld e,(hl)           ;E <- length
    pop hl              ;HL <- data structure address
    push bc
    ld b,_result_offset_td
    call ArrayAccess_ne ;HL <- diameter array address
    pop bc              ;B <- index
    call ArrayAccess
    ld d,(hl)           ;D <- diameter

    ;loop
    ld a,(LCV_size)
    ld b,a              ;B <- LCV_size
    ld hl,LCV
FindInLCV_loop:
    ;search for length
    ld a,e              ;A <- length
    push bc
    push de
    call FindByte       ;find length in LCV
    jp z,FindInLCV_notfound

    ;check to see if criteria pass
    ld b,d              ;B <- index of found element in LCV
    pop de              ;D <- diameter, E <- length
    push hl
    call CriteriaPassFail
    jp nc,FindInLCV_found

    ;calculate the number of elements left in the LCV
    pop hl              ;HL <- recent LCV index address
    pop af              ;A <- LCV index of previously found length element
    sub b               ;A <- (previous LCV leftover size) - (recent LCV index)
    jp z,FindInLCV_notfound_exit
    dec a               ;A <- new LCV leftover size
    ld c,a              ;C <- new LCV leftover size
    ld b,0
    add hl,bc           ;HL <- new starting LCV index address
    ld b,c              ;B <- new LCV leftover size

    ;continue looping
    jp FindInLCV_loop
FindInLCV_found:
    ;clean the stack
    pop hl              ;get this off the stack
    pop hl              ;get this off the stack

    ;load outputs
    ;/ no need, B is already loaded

    ;reset zero flag
    push bc
    call ResetZeroFlag
    pop bc

    ;return
    ret
FindInLCV_notfound:
    ;clean the stack
    pop de              ;get this off the stack
    pop de              ;get this off the stack

FindInLCV_notfound_exit:
    ;set zero flag
    call SetZeroFlag

    ;return
    ret


