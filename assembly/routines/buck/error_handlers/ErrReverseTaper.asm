
   
;============================================================
; ErrReverseTaper -- jumped to from Interpolate if reverse 
;                   tree taper is encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Interpolate routine
;  total: 16b
;  tested: yes
;============================================================
    .db 0  ;count occurences
ErrReverseTaper: 
    ld hl,err_occured
    ld (hl),1
    ld hl,ErrReverseTaper-1
    inc (hl)
    pop de
    ld d,0
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Interpolate_endIntpolat
    
