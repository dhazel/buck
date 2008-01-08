

;===============================================================================
; ByteLShift -- shifts the specified number of bytes one address to the left,
;               overwriting the first byte
;  input:   B == number of bytes to shift plus byte to overwrite
;           HL == address of first byte
;  output:  shifted bytes
;  affects: DE -- destroyed
;           HL -- destroyed
;           A  -- destroyed
;           B  -- destroyed
;  total: 12b
;  tested: yes
;===============================================================================
ByteLShift:
    ld d,h
    ld e,l
    inc hl
ByteLShift_loop:    ;iteratively copies (HL) into (DE)
    ; input:    B == number of bytes to shift
    ;
    ld a,(hl)
    ld (de),a

    inc hl
    inc de

    dec b
    jp p,ByteLShift_loop

    ret             ;return

