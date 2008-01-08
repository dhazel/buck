

;============================================================
; SumWrdArray -- adds all elements of a dataword array
;  input: IX = pointer to the array
;         B  = length of array (starting from zero)
;  output: HL = the sum of the elements
;  affects: IX -> points past end of array
;           DE -> holds last element of array
;           C = B
;  total: 20b/127t (minimum (no looping), including ret)
;  tested: yes
;============================================================
SumWrdArray:
    ld c,b       ;save B for later
    inc b        ;reference B from 1 rather than 0
    ld hl,0      ;set HL == 0
SumWrdArrayFor:
    ld d,(ix)
    inc ix
    ld e,(ix)
    inc ix
    add hl,de
    djnz SumWrdArrayFor  ;Note>> includes dec b
    ld b,c
    ret

