

;============================================================
; PrintArray -- prints an array of databytes to the screen
;  input: IX = pointer to the array
;         B  = length of the array (starting from 1)
;  output: numbers printed to screen
;  affects: B -> 0
;           IX -> pointer past end of array
;           A -> destroyed
;           HL -> destroyed
;  total: 14b/80t (minimum (no looping), including ret)
;  tested: yes
;============================================================
PrintArray:
;  ld hl,_curCol
;  dec (hl)
PrintArrayFor:
    xor a        ;set A == 0
    ld h,0       ;set H == 0
    ld l,(ix)
    inc ix
    call _dispAHL
    djnz PrintArrayFor  ;Note>> includes dec b
    ret
    
