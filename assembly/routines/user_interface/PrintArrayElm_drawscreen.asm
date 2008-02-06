

;============================================================
; PrintArrayElm_drawscreen -- special element printer for the
;           CriteriaEditor and BCLP2 drawscreen routines
;  input: IX = pointer to the array
;         C  = element offset (starting from zero)
;         LCV_size
;         A = 0 if we want to print a simple yes (if number) or no (of zero)
;         A = 1 if we want to print the element, empty space at 0's and 255's
;         A = 2 if we want to print the element, and "no" at 0's
;  output: numbers or words printed to screen
;  affects: varies
;  total: 87b
;  tested: yes
;============================================================
PrintArrayElm_drawscreen:
    ld b,0       ;set B == 0
    ld h,0       ;set H == 0
    add ix,bc
    cp 0
    jp z,PrintArrayElm_drawscreen_yesno
    cp 1
    jp z,PrintArrayElm_drawscreen_element
    cp 2
    jp z,PrintArrayElm_drawscreen_elementno
    ret
PrintArrayElm_drawscreen_yesno:
    ld a,(ix)
    cp 0
    jp z,PrintArrayElm_drawscreen_no
    jp PrintArrayElm_drawscreen_yes
PrintArrayElm_drawscreen_element:
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
PrintArrayElm_drawscreen_elementno:
    ld l,(ix)
    ld a,0       ;if element is zero print empty space
    cp l
    jp z,PrintArrayElm_drawscreen_no
    xor a        ;set A == 0
    call _dispAHL                      ;print (elem - 1)
    ret                                ;return
PrintArrayElm_drawscreen_empty:
    ld hl,clearselection_text
    call _puts
    ret
PrintArrayElm_drawscreen_no:
    ld hl,no_text
    call _puts
    ret
PrintArrayElm_drawscreen_yes:
    ld hl,yes_text
    call _puts
    ret

