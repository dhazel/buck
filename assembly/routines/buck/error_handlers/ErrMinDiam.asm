

;============================================================
; ErrMinDiam -- jumped do from Volume if a minimum diameter 
;                   size is encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 26b
;  tested: yes
;============================================================
    .db 0  ;count occurences
    .db 5  ;greatest error margin (minimum diameter is 5 inches)
ErrMinDiam:
    ld hl,err_occured
    ld (hl),1
    ld hl,ErrMinDiam-2
    inc (hl)
    inc hl
    cp (hl) ;keep track of greatest error margin
    jp nc,ErrMinDiam_overerr
    ld (hl),a
ErrMinDiam_overerr:
    dec a     ;<--.-for consistancy with the routine
    ld c,a    ;<-/
    push bc   ;</
    call _op1set0   ;volume = zero
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Volume_fi7
   
