
    
;============================================================
; SumBytArray -- adds all elements of a databyte array
;  input: HL = pointer to the array
;         B  = length of array (that we care about)
;  output: A = the sum of the elements
;  affects: HL <- pointer to end of array
;           C <- B
;  total: 9b/65t (minimum (no looping), including ret)
;  tested: yes
;============================================================
SumBytArray:
    ld c,b       ;save B for later
    inc b        ;reference B from 1 rather than 0
    xor a        ;set A == 0
SumBytArrayFor:
    add a,(hl)
    inc hl
    djnz SumBytArrayFor  ;Note>> includes dec b
    ld b,c
    ret
    
