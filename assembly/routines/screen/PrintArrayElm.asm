

;============================================================
; PrintArrayElm -- prints an array element to the screen
;  input: IX = pointer to the array
;         C  = element offset (starting from zero)
;  output: numbers printed to screen
;  affects: B -> 0
;           HL -> destroyed
;           A -> destroyed
;  total: 14b/79t (excluding called functions, including ret)
;  tested: yes
;============================================================
PrintArrayElm:
    xor a        ;set A == 0
    ld b,0       ;set B == 0
    ld h,0       ;set H == 0
    add ix,bc
    ld l,(ix)
    call _dispAHL
    ret

