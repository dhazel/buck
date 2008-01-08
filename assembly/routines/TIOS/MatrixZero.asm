

;===============================================================================
; MatrixZero -- fills the desired (real) matrix with zeros
;  input:   HL == points to name of matrix excluding type byte (lngth initlzd)
;  output:  TIOS matrix variable filled with zeros
;           zero flag is set if the matrix variable does not exist
;  affects: assume everything
;  total: 47b
;  tested: yes
;===============================================================================
MatrixZero:
    push hl

    ;get matrix dimensions
    ld a,3
    call MatrixAccess       ;D <- rows ;E <- columns
    jp z,MatrixZero_nomatrix
    pop hl
    push de
    
    ;fill the current row with zeros
MatrixZero_rowfill_loop:    ;iterate on E
    push de
    push hl
    call _op1set0           ;op1 <- 0
    pop hl
    pop de
    push de
    push hl
    ld a,1                  ;write
    call MatrixAccess       ;matrix element <- op1
    pop hl
    pop de
    dec e
    jp nz,MatrixZero_rowfill_loop

    ;decrement the column, check for zero, and zero out the next row
    pop de
    dec d
    push de
    jp nz,MatrixZero_rowfill_loop

    ;clean the stack, the flags, and return
    pop de
    call ResetZeroFlag  ;reset the necessary flags
    call ResetCarryFlag
    ret
MatrixZero_nomatrix:
    pop hl
    ret

