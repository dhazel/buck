
          
;==============================================================================
; save_data -- This is a highly optimized writeback routine for saving high 
;                   scores and saved games. 
;   NOTE: saves all data between data_start and data_end.
;-Jonah Cohen       <ComAsYuAre@aol.com>
;==============================================================================
save_data:
    ld hl,_asapvar                      ;hl->name of program
    rst 20h                             ;copy to OP1
    rst 10h                             ;_findsym
    xor a
    ld hl,data_start-_asm_exec_ram+4    ;offset
    add hl,de                           ;hl=pointer to data in original prog
    adc a,b                             ;in case we overlapped pages
    call _set_abs_dest_addr
    xor a                               ;no absolute addressing now
    ld hl,data_start                    ;get data from here
    call _set_abs_src_addr
    ld hl,data_end-data_start           ;number of bytes to save
    call _set_mm_num_bytes
    jp _mm_ldir                         ;copy data and return

