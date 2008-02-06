

;============================================================
; SwitchMill -- Saves the current mill's data, and switches the current mill 
;               with whatever mill is indicated by the 'mill_number' variable.
;               Checks that the corresponding statistics data is present
;               and initializes it if needed.
;  input: mill_number
;  output: current mill is saved and switched out for a new
;           one
;  affects: assume everthing
;  total: 122b
;  tested: yes
;   NOTE: the mill_number is indexed from zero
;   NOTE: if the mill number is bad, then nothing happens
;============================================================
SwitchMill:
    ;write current mill data into mill storage
    xor a                   ;aka, ld a,0
    ld hl,mill_name         ;start of current mill data
    call _set_abs_src_addr  ;set that as source address
    ld hl,data_LP_end - mill_name
    call _set_mm_num_bytes  ;set the number of bytes to save

    ld a,(currentmill_number)
    call SwitchMill_branch
SwitchMill_save_data:
    call _set_abs_dest_addr
    call _mm_ldir      ;write _mm_num_bytes from _abs_src_addr to _abs_dest_addr

    ;load mill_number mill into mill data
    xor a                   ;aka, ld a,0
    ld hl,mill_name         ;start of current mill data
    call _set_abs_dest_addr ;set that as source address
    ld hl,data_LP_end - mill_name
    call _set_mm_num_bytes  ;set the number of bytes to save

    ld a,(mill_number)
    call SwitchMill_branch
    push de                 ;pointer to mill statdata matrix name
SwitchMill_load_data:
    call _set_abs_src_addr
    call _mm_ldir      ;write _mm_num_bytes from _abs_src_addr to _abs_dest_addr

    ;save the data
    call save_data

    ;check that the statdata matrix is present and initialized
    pop hl                  ;pointer to mill statdata matrix name
    ld d,1                  ;row 1
    ld e,1                  ;column 1
    ld a,0                  ;read element
    call MatrixAccess
    jp z,SwitchMill_statdata_init

    call _op2set0           ;op2 <- 0
    call _cpop1op2          ;cp op1,op2
    jp nz,SwitchMill_statdata_noinit
SwitchMill_statdata_init:
    ld a,0                  ;init the matrix
    call StatDataInit
SwitchMill_statdata_noinit:
    ret  ;return
    ;
SwitchMill_branch:
    cp 0
    jp z,SwitchMill_move_mill1
    cp 1
    jp z,SwitchMill_move_mill2
    cp 2
    jp z,SwitchMill_move_mill3
    pop hl
    ret ;return, bad mill number
SwitchMill_move_mill1:
    xor a
    ld hl,mill1_name
    ld de,mill1_matrix_name
    ret
SwitchMill_move_mill2:
    xor a
    ld hl,mill2_name
    ld de,mill2_matrix_name
    ret
SwitchMill_move_mill3:
    xor a
    ld hl,mill3_name
    ld de,mill3_matrix_name
    ret
        
