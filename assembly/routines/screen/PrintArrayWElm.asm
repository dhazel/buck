

;============================================================
; PrintArrayWElm -- prints a big-endian word-array element to
;                       the screen
;  input: IX = pointer to the array
;         C  = element offset (starting from zero)
;  output: numbers printed to screen
;  affects: B -> 0
;           HL -> destroyed
;           A -> destroyed
;           IX -> points to LS-Byte of element
;  total: 21b/119t (excluding called functions, including ret)
;  tested: yes
;============================================================
PrintArrayWElm:
    xor a        ;set A == 0
    ld b,0       ;set B == 0
    sla c        ;multiply indicy number by 2
    add ix,bc
    ld h,(ix)
    inc ix
    ld l,(ix)
    inc ix
    call _dispAHL
    ret

