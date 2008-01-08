

;============================================================
; SumWrdArray_rel -- Adds all elements of a dataword array
;           relative to a second dataword array. If an 
;           element in the second array is zero, then the 
;           corresponding element in the first array is 
;           skipped.
;  input: IX = pointer to the array
;         B  = length of array (starting from zero)
;         HL = pointer to the second array
;  output: HL = the sum of the elements
;  affects: IX -> points past end of array
;           DE -> points to the last element of the rel array
;           * does not affect BC
;  total: 82b/487t (minimum (no looping), including ret)
;  tested: yes
;============================================================
SumWrdArray_rel:
    push bc         ;save B for later
    inc b           ;reference B from 1 rather than 0
    push ix         ;pointer to array to be summed
    push hl         ;pointer to relative array
    ld hl,0         ;set HL == 0
SumWrdArray_relFor:
    ;check relative array for zero
    pop ix          ;IX <- pointer to relative array
    push bc         ;index variable
    ld d,0                      
    ld a,(ix)                   
    cp 0
    jp z,SumWrdArray_relFor_norelbyte1
    ld d,1
SumWrdArray_relFor_norelbyte1:
    inc ix
    ld a,(ix)
    cp 0
    jp z,SumWrdArray_relFor_norelbyte2
    ld d,1
SumWrdArray_relFor_norelbyte2:
    inc ix
    push ix                 ;pointer to rel array
    pop bc                  ;BC <- pointer to rel array
    pop af                  ;AF <- index variable
    pop ix                  ;IX <- pointer to first array
    push af                 ;index variable
    push bc                 ;pointer to rel array
    
    ;if not zero, add in corresponding element
    ld a,d
    cp 0
    jp z,SumWrdArray_relFor_norelwrd
    ld d,(ix)               ;add element to HL
    inc ix
    ld e,(ix)
    inc ix
    add hl,de
    jp SumWrdArray_relFor_continue
SumWrdArray_relFor_norelwrd:
    inc ix
    inc ix
SumWrdArray_relFor_continue:
    pop de                  ;DE <- pointer to rel array
    pop bc                  ;BC <- index variable
    push ix                 ;pointer to first array
    push de                 ;pointer to rel array
    djnz SumWrdArray_relFor  ;Note>> includes dec b
    pop ix                  ;get this off the stack
    pop ix                  ;get this off the stack
    pop bc                  ;recall B
    ret

