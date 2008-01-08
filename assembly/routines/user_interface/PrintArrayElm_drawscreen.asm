

;============================================================
; PrintArrayElm_drawscreen -- special element printer for the
;           CriteriaEditor and BCLP2 drawscreen routines
;  input: IX = pointer to the array
;         C  = element offset (starting from zero)
;         LCV_size
;  output: numbers printed to screen
;          if the number is either zero or 255, then empty space is printed
;  affects: B -> 0
;           HL -> destroyed
;           A -> destroyed
;  total: 32b/155t (excluding called functions, including ret)
;  tested: yes
;============================================================
PrintArrayElm_drawscreen:
    ld b,0       ;set B == 0
    ld h,0       ;set H == 0
    add ix,bc
    ld l,(ix)
    ld a,0       ;if element is zero print empty space
    cp l
    jp z,PrintArrayElm_drawscreen_empty
    dec a        ;if element is 255 print empty space also
    cp l
    jp z,PrintArrayElm_drawscreen_empty
    xor a        ;set A == 0
    call _dispAHL                      ;print (elem - 1)
    ret                                ;return
PrintArrayElm_drawscreen_empty:
    ld hl,clearselection_text
    call _puts
    ret

