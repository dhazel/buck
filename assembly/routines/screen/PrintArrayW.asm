

;============================================================
; PrintArrayW -- prints an array of big endian datawords to 
;                   the screen
;  input: IX = pointer to the array
;         B  = length of the array
;  output: numbers printed to screen
;  affects: B -> 0
;           IX -> pointer past end of array
;           A -> destroyed
;           HL -> destroyed
;  total: 17b/102t (minimum (no looping), including ret)
;  tested: yes
;============================================================
PrintArrayW:
;  ld hl,_curCol
;  dec (hl)
PrintArrayWFor:
    xor a        ;set A == 0
    ld h,(ix)
    inc ix
    ld l,(ix)
    inc ix
    call _dispAHL
    djnz PrintArrayWFor  ;Note>> includes dec b
    ret
    
