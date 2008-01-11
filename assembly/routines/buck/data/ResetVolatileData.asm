

;============================================================
; ResetVolatileData -- Resets all volatile data 
;  input: data_volatile_end
;         data_volatile_start
;  output: volatile data (see bc_data.asm) is filled with 
;           zeros, error counters are reset, min_length is 
;           set to 255, 'it' array is set to 255's, 'length' 
;           value is copied into 'Li'
;  affects: assume everthing
;  total: 33b
;  tested: yes
;============================================================
ResetVolatileData:
    ld b,data_volatile_end - data_volatile_start
    ld hl,data_volatile_start
    call _ld_hl_bz              ;zero out all 'volatile' memory
    ld hl,min_length
    dec (hl)                    ;roll min_length over to 255
    ld a,(length)               ;copy length value into 'Li'
    ld (Li),a
    ld hl,it            ;roll all "it" values over to 255
    ld a,(LCV_size)
    ld (hl),a           ;this could be better, but I am in a hurry
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a

    ret

