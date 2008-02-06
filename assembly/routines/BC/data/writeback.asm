

;===============================================================================
; writeback -- Copies the data block (everything between data_start and 
;                   data_end) back into BC
;   input:  none
;   affects: assume everthing
;   total: 7b (including ret)
;   tested: yes
;===============================================================================
writeback:
    ld hl,pname_MainBuckingCalculator
    call copyover_data
    ret

