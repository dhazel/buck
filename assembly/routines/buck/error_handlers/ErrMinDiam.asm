

;============================================================
; ErrMinDiam -- jumped do from Volume if a minimum diameter 
;                   size is encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 29b
;  tested: yes
;============================================================
ErrMinDiam:
    ld hl,err_occured
    ld (hl),1
    ld hl,err_MinDiam_occured
    inc (hl)
    ld hl,err_MinDiam_bound
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
   
