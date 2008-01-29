






;===============================================================================
; ArrayToMatRow -- copies the a databyte or dataword array into the specified 
;               matrix row
;  input:   HL == points to name of matrix excluding type byte (lngth initlzd)
;           BC == points to the data array
;           D == row number (starting from 1)
;           E == length of array (starting from 1)
;           A - if A == 1, then array is considered to be a dataword array
;               else, array is considered to be a databyte array
;  output:  array of data copied into matrix row
;           zero flag is set if the matrix variable does not exist
;           carry flat is set if the array overruns the matrix
;  affects: assume everything
;  total: 90b
;  tested: yes
;===============================================================================
ArrayToMatRow:
    ;save inputs to stack
    push de                 ;row, array length
    ld e,1
    push de                 ;row, column
    push hl                 ;matrix name pointer
    push bc                 ;array pointer
    push af                 ;array type designator
ArrayToMatRow_loop:
    ;get data element
    pop af                  ;A <- array type designator
    cp 1
    jp nz,ArrayToMatRow_loop_byte
ArrayToMatRow_loop_word:
    pop hl                  ;HL <- address of dataword element
    ld d,(hl)
    inc hl
    ld e,(hl)               ;DE <- dataword
    jp ArrayToMatRow_loop_setOP1
ArrayToMatRow_loop_byte:
    pop hl                  ;HL <- address of dataword element
    ld d,0
    ld e,(hl)               ;E <- databyte
ArrayToMatRow_loop_setOP1:
    inc hl                  ;increment array pointer
    push hl
    ld h,d
    ld l,e                  ;HL <- DE
    push af
    call _setXXXXop2        ;op2 <- HL
    call _ex_op1_op2        ;op1 <- op2

    ;write data element into matrix element
    pop af                  ;A <- array type designator
    pop bc                  ;BC <- array pointer
    pop hl                  ;HL <- matrix name pointer
    pop de                  ;D <- row, E <- column
    push de
    push hl
    push bc
    push af
    ld a,1                  ;write
    call MatrixAccess       ;matrix element <- op1
    jp z,ArrayToMatRow_earlyreturn ;no matrix found, return
    jp c,ArrayToMatRow_earlyreturn ;beyond matrix dimensions, return 

    ;increment columns and decrement iterator
    pop af                  ;A <- array type designator
    pop bc                  ;BC <- array pointer ;(already incremented above)
    pop hl                  ;HL <- matrix name pointer
    pop de                  ;D <- row, E <- column
    inc e
    exx                     ;qq<->qq' ;register pairs exchanged
    pop de                  ;D <- row, E <- array length
    dec e
    jp nz,ArrayToMatRow_loop_continue
    jp ArrayToMatRow_return
ArrayToMatRow_loop_continue:   ;loop
    push de
    exx                     ;qq<->qq' ;register pairs exchanged
    push de
    push hl
    push bc
    push af
    jp ArrayToMatRow_loop
ArrayToMatRow_earlyreturn: ;error encountered, return with the thrown flag
    pop af                  ;get these off the stack
    pop bc
    pop hl
    pop de
    pop de
    ret
ArrayToMatRow_return:  ;return pleasantly
    ;finish up and return, status = good
    call ResetZeroFlag  ;reset the necessary flags
    call ResetCarryFlag
    ret

