
   
;============================================================
; ErrReverseTaper -- jumped to from Interpolate if reverse 
;                   tree taper is encountered
;  NOTE: This is a special error handler routine designed
;           specifically for the Interpolate routine
;  total: 18b
;  tested: yes
;============================================================
ErrReverseTaper: 
    ld hl,err_occured
    ld (hl),1
    ld hl,err_ReverseTaper_occured
    inc (hl)
    pop de
    ld d,0
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Interpolate_endIntpolat
    
