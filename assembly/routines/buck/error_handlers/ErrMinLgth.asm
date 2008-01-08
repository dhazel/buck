
   
;============================================================
; ErrMinLgth -- jumped to from Volume if a minimum length is 
;                   encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 37b
;  tested: yes
;============================================================
    .db 0  ;count occurences
    .db 1  ;greatest error margin (minimum length is 1 foot)
ErrMinLgth:
    ld ix,err_occured
    ld (ix),1
    ld ix,ErrMinLgth-2
    inc (ix)
    inc ix
    cp (ix) ;keep track of greatest error margin
    jp nc,ErrMinLgth_overerr
    ld (ix),a
ErrMinLgth_overerr:
    push hl   ;<--.-for consistancy with the routine
    ld c,a    ;<-/
    push bc   ;</
    call _op1set0   ;volume = zero
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Volume_fi7

