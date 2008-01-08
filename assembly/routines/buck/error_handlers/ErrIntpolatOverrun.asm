
   
;============================================================
; ErrIntpolatOverrun -- jumped to from Interpolate if an 
;                   interpolation overrun occurs
;  NOTE: This is a special error handler routine designed
;           specifically for the Interpolate routine
;  total: 15b
;  tested: yes
;============================================================
    .db 0  ;count occurences
ErrIntpolatOverrun: 
    ld hl,err_occured
    ld (hl),1
    ld hl,ErrIntpolatOverrun-1
    inc (hl)
    ld d,0
#ifdef DEBUG
    call VarDump ;BLAMMO!!!
#endif
    jp Interpolate_endIntpolat

