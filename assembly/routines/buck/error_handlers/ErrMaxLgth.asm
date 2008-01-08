

;============================================================
; ErrMaxLgth -- jumped to from Volume if a maximum length is 
;                   encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 37b
;  tested: yes
;============================================================
    .db 0  ;count occurences
    .db 40 ;greatest error margin (maximum length is 40 feet)
ErrMaxLgth:
    ld ix,err_occured
    ld (ix),1
    ld ix,ErrMaxLgth-2
    inc (ix)
    inc ix
    cp (ix) ;keep track of greatest error margin
    jp c,ErrMaxLgth_overerr
    ld (ix),a
ErrMaxLgth_overerr:
    push hl   ;<--.-for consistancy with the routine
    ld c,a    ;<-/
    push bc   ;</
    call _op1set0   ;volume = zero
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Volume_fi7
   
