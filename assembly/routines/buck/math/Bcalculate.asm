






;===============================================================================
; Bcalculate -- calculates the value of the given tree based on specific log
;               lengths and diameters (not the same as Buck), also populates
;               the corresponding data-structure result variables
;  input:   IX  = pointer to start of the data structure
;               (this is the "result" datastructure, and the first two
;                   variables (the lengths and diameters arrays) must contain
;                   data to be used for calculation)
;  output:  the rest of the datastructure (supplied at input) is populated
;  affects: assume everything
;  total: 186b (excluding func calls, including ret)
;  tested: yes
;===============================================================================
Bcalculate:
    ;preload the LCV_index array with 255's
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_LCV_index; LCV_index array offset
    call ArrayAccess_ne ;HL <- LCV_index array address
    ld b,_log_entries + 1
Bcalculate_preloadloop:
    ld (hl),255
    inc hl
    dec b
    jp nz,Bcalculate_preloadloop

    ;enter the calculation loop
    ld b,0
Bcalculate_loop:

    ;check for array overrun
    ld hl,$             ;load HL with address of this location
    push hl             ;push HL for use by s_Overrun error routine
    ld a,b
    cp _log_entries + 1
    jp nc,Err_s_Overrun
    pop hl              ;get this off the stack

    ;find our current log in the LCV
    push ix
    pop hl              ;HL <- start address of the "result" datastructure
    push bc
    call FindInLCV
    jp z,Bcalculate_loop_continuecheck
    
    ;prep for volume routine
    ld hl,LCV
    call ArrayAccess_ne
    pop af              ;A <- "result" datastructure array index
    push bc             ;SP(1) <- B == current LCV index
    push hl             ;SP(0) <- pointer to length of log
    ld b,a              ;B <- "result" datastructure array index

    ;calculate volume
    call Volume
    pop bc              ;B <- array index, C <- (length - trim)
    inc c               ;add trim back into length

    ;save volume
    push bc
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_v; volume array offset
    call ArrayAccess_ne ;HL <- volume array address
    pop bc              ;B <- array index, C <- length
    call ArryAccessW
    ld (hl),d
    inc hl
    ld (hl),e

    pop de              ;pointer to length (un-needed remnant from Volume)
    pop af              ;A <- current LCV index
    push af

    ;calculate price
    push bc             ;B == array index, C == length
    push ix
    ld b,a              ;B <- current LCV index
    call Price2standalone
    pop ix              ;IX <- address of "result" datastructure
    pop bc              ;B <- array index, C <- length

    ;save price
    push bc
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_p; price array offset
    call ArrayAccess_ne ;HL <- price array address
    pop bc              ;B <- array index
    call ArryAccessW
    ld (hl),d
    inc hl
    ld (hl),e

    ;save LCV index
    push bc
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_LCV_index; LCV_index array offset
    call ArrayAccess_ne ;HL <- LCV_index array address
    pop bc              ;B <- array index
    call ArrayAccess
    pop af              ;A <- current LCV index
    ld (hl),a

    ;continue loop??
    push bc
Bcalculate_loop_continuecheck:
    pop bc              ;B <- our input index
    ld a,b              ;are we at the end of the array?
    inc b
    cp _log_entries
    jp c,Bcalculate_loop
Bcalculate_loop_end:
    dec b

    ;sum price array
    push bc
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_p; price array offset
    call ArrayAccess_ne ;HL <- price array address
    pop bc              ;B <- array index (length of array)
    push ix
    push hl
    pop ix              ;IX <- price array address
    call SumWrdArray    ;HL <- sum of price array elements
    pop ix              ;IX <- start address of "result" datastructure

    ;load sum data      (note byte order of these word-size loads!)
    ld (ix + _result_offset_sum_p),l
    ld (ix + _result_offset_sum_p + 1),h

    ;sum volume array
    push ix             ;saved for later
    push bc
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_v; volume array offset
    call ArrayAccess_ne ;HL <- volume array address
    push hl
    push ix
    pop hl              ;HL <- start address of "result" datastructure
    ld b,_result_offset_p; price array offset
    call ArrayAccess_ne ;HL <- price array address
    pop ix              ;IX <- volume array address
    pop bc              ;B <- array index (length of array)
    call SumWrdArray_rel ;HL <- sum of relevant volume array elements
    pop ix              ;IX <- start address of "result" datastructure

    ;load sum data      (note byte order of these word-size loads!)
    ld (ix + _result_offset_sum_v),l
    ld (ix + _result_offset_sum_v + 1),h

    ret
