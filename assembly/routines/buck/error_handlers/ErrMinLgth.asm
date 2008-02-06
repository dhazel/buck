
   
;============================================================
; ErrMinLgth -- jumped to from Volume if a minimum length is 
;                   encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 40b
;  tested: yes
;============================================================
ErrMinLgth:
    ld ix,err_occured
    ld (ix),1
    ld ix,err_MinLgth_occured
    inc (ix)
    ld ix,err_MinLgth_bound
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

