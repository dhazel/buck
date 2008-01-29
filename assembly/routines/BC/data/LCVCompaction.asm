

;===============================================================================
; LCVCompaction -- copies the LCV into LCVcompact and removes all repeat 
;               elements from the data
;  input:   LCV
;           LCV_size
;  output:  LCVcompact <- compacted LCV
;           LCVcompact_size <- size of compacted LCV
;  affects: assume everything
;  total: 71b
;  tested: yes
;===============================================================================
    jp LCVCompaction        ;just in case
;LCVcompact is where the LCV is copied when repeat elements are removed for the 
;   statistics matrices
LCVcompact: .db 17,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255 
LCVcompact_size: .db 0 ;number of elements (starting from 0) in LCVcompact
;---------------------------
LCVCompaction:
    ;copy LCV_size into LCVcompact_size
    ld a,(LCV_size)
    ld (LCVcompact_size),a

    ;copy LCV into LCVcompact
    inc a
    push af                     ;save this for later
    inc a
    ld c,a                      ;BC <- number of LCV elements
    ld b,0
    ld hl,LCV                   ;HL <- source address
    ld de,LCVcompact            ;DE <- destination address
    push de                     ;save DE for later
    ldir                        ;copy the stuff over

    pop hl                      ;address of current array element
    pop bc                      ;B <- number of array elements remaining

    ;iterate over each element until the end is reached
LCVCompaction_loop:
    ld a,(hl)
    inc hl
    dec b
    ret z                       ;RETURN IS HERE!!! 

    push hl                     ;address of current array element
    push bc                     ;B == number of array elements remaining
LCVCompaction_loop_deleteloop:
    ; find duplicates and remove them until the end is reached
    push af                     ;A == search value
    push bc                     ;B == number of array elements remaining
    call FindByte
    jp z,LCVCompaction_loop_continue   ;not found, loop again

    ;delete the found element
    pop af                      ;A <- number of array elements remaining
    sub d                       ;A <- new number of remaining elements
    ld b,a                      ;B <- number of array elements remaining
    dec a
    push af                     ;A == future number of elements remaining
    push hl                     ;HL == address of current (found) array element
    call ByteLShift             ;effectively delete current array element

    ;prep and continue loop
    ld hl,LCVcompact_size
    dec (hl)                    ;decrease array size indicator
    pop hl                      ;HL <- address of current array element
    pop bc                      ;B <- number of elements remaining
    pop af                      ;A <- search value
    pop de                      ;D <- # of remaining elements in parent loop
    dec d
    jp z,LCVCompaction_special_return
    push de
    jp LCVCompaction_loop_deleteloop
LCVCompaction_loop_continue:
    pop bc                      ;get this off the stack
    pop af                      ;get this off the stack
    pop bc                      ;B <- number of array elements remaining
    pop hl                      ;address of current array element
    jp LCVCompaction_loop
LCVCompaction_special_return:
    ;this should only be reached if the delete loop takes the array down
    ;   to the zero'th element
    pop hl      ;get this off the stack
    ret         ;return

