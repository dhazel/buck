

;============================================================
; ClearErrors -- resets all error data fields to original
;                   values
;  input: -none- requires the error handlers
;  output: resets all error data fields
;  affects: most everything
;  total: 71b/290t (including ret)
;  tested: yes
;============================================================
ClearErrors:
    ld a,0                      ;reset FinMenu_menu_data error display settings
    ld (FinMenu_menu_data + 8),a

    ld hl,err_occured           ;reset the err_occured notification variable
    ld (hl),0
    
    ld hl,ErrMinDiam-2
    ld (hl),0
    ld hl,ErrMinDiam-1
    ld (hl),5
    
    ld hl,ErrMaxDiam-2
    ld (hl),0
    ld hl,ErrMaxDiam-1
    ld (hl),32

    ld hl,ErrMinLgth-2
    ld (hl),0
    ld hl,ErrMinLgth-1
    ld (hl),1

    ld hl,ErrMaxLgth-2
    ld (hl),0
    ld hl,ErrMaxLgth-1
    ld (hl),40

    ld hl,ErrReverseTaper-1
    ld (hl),0

    ld hl,ErrIntpolatOverrun-1
    ld (hl),0
    
    ret

