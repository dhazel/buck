

;============================================================
; ClearErrors -- resets all error data fields to original
;                   values
;  input: -none- requires the error handlers
;  output: resets all error data fields
;  affects: most everything
;  total: 61b/250t (including ret)
;  tested: yes
;============================================================
ClearErrors:
    ld a,0                      ;reset FinMenu_menu_data error display settings
    ld (FinMenu_menu_data + 8),a

    ld hl,err_occured
    ld (hl),0
    
    ld hl,err_MinDiam_occured
    ld (hl),0
    ld hl,err_MinDiam_bound
    ld (hl),_minimum_top_diameter
    
    ld hl,err_MaxDiam_occured
    ld (hl),0
    ld hl,err_MaxDiam_bound
    ld (hl),_maximum_top_diameter

    ld hl,err_MinLgth_occured
    ld (hl),0
    ld hl,err_MinLgth_bound
    ld (hl),1   ;determined at runtime

    ld hl,err_MaxLgth_occured
    ld (hl),0
    ld hl,err_MaxLgth_bound
    ld (hl),_maximum_log_length

    ld hl,err_ReverseTaper_occured
    ld (hl),0

    ld hl,err_IntpolatOverrun_occured
    ld (hl),0

    ret

