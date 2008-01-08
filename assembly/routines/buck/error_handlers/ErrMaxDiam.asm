
  
;============================================================
; ErrMaxDiam -- jumped to from Volume if a maximum diameter 
;                   size is encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Volume routine
;  total: 26b
;  tested: yes
;============================================================
    .db 0  ;count occurences
    .db 32 ;greatest error margin (maximum diameter is 32 inches)
ErrMaxDiam:
    ld hl,err_occured
    ld (hl),1
    ld hl,ErrMaxDiam-2
    inc (hl)
    inc hl
    cp (hl) ;keep track of greatest error margin
    jp c,ErrMaxDiam_overerr
    ld (hl),a
ErrMaxDiam_overerr:
    dec a     ;<--.-for consistancy with the routine
    ld c,a    ;<-/
    push bc   ;</
    call _op1set0   ;volume = zero
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Volume_fi7
    
