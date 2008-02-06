

;===============================================================================
; copyover_volatile -- This is a data sharing routine. It copies the volatile 
;                   block (between data_inputs_start and data_results_end) from 
;                   the current program into another program or TIOS variable. 
;                   The data must be in exactly the same byte location in each 
;                   program or variable.
;   input:  HL = pointer to program or variable name string (length initialized)
;           data_inputs_start = start of data block
;           data_results_end = end of data block
;   affects: assume everthing
;   total: 29b (including ret)
;   tested: yes
;   NOTE: This is a slight modification of Jonah Cohen's highly optimized 
;           writeback routine for saving high scores and saved games. It copies 
;           all data between data_inputs_start and data_results_end.
;===============================================================================
copyover_volatile:
    dec hl                              ;copy anything before string name for
                                        ; type byte
    rst 20h                             ;copy to OP1
    rst 10h                             ;_findsym
    ret c                               ;if not present, return gracefully
    xor a
    ld hl,data_inputs_start-_asm_exec_ram+4    ;offset
    add hl,de                           ;hl=pointer to data in original prog
    adc a,b                             ;in case we overlapped pages
    call _set_abs_dest_addr
    xor a                               ;no absolute addressing now
    ld hl,data_inputs_start             ;get data from here
    call _set_abs_src_addr
    ld hl,data_results_end-data_inputs_start   ;number of bytes to save
    call _set_mm_num_bytes
    jp _mm_ldir                         ;copy data and return

