

;============================================================
; ExportResults -- Exports the result data variables to the TIOS via the bcout
;           matrix variable, according to the program specification
;  input: A == choice number by FinDisplay column starting from 1
;  output: the TIOS matrix variable, bcout, is updated
;            - .-------------.-------------.-----------.----------.
;              |state_status | mill_number | butt_diam | undoable |
;              |-------------^-------------^-----------^----------|
;              |lengths array                                     |
;              |--------------------------------------------------|
;              |volumes array                                     |
;              |--------------------------------------------------|
;              |prices array                                      |
;              |--------------------------------------------------|
;              |diameter array                                    |
;              |--------------------------------------------------|
;              |LCV index array                                   |
;              *--------------------------------------------------*
;              - state status variable
;                - toggled between 0 and 1 to designate fresh and stale data
;                   respectively
;           - carry flag is set and nothing is done if the matrix still contains
;               fresh data
;  affects: assume everything
;  total: 273b
;  tested: yes
;============================================================
    jp ExportResults        ;just in case
ExportResults:
    ;determine choice data
    cp 1
    jp nz,ExportResults_check_choice2
    ld bc,_FinDisplay_offset_col1_data
    jp ExportResults_choice_chosen
ExportResults_check_choice2:
    cp 2
    jp nz,ExportResults_check_choice3
    ld bc,_FinDisplay_offset_col2_data
    jp ExportResults_choice_chosen
ExportResults_check_choice3:
;   cp 3
;   jp nz,ExportResults_check_choice4
    ld bc,_FinDisplay_offset_col3_data
;   jp ExportResults_choice_chosen
ExportResults_choice_chosen:
    ld ix,(FinDisplay_data_pointer)
    add ix,bc                   ;add offset to choice data pointer pointer
    ld h,(ix + 1)               ;load the choice data pointer into HL
    ld l,(ix + 0)
    push hl                     ;save HL for later

    ;check matrix dimensions to make sure it has not been messed with
    ld hl,output_matrix_name
    ld a,3                      ;output dimensions to DE 
    call MatrixAccess           ;D <- rows ;E <- columns
    jp z,ExportResults_initmatrix   ;if matrix is gone, initialize it
    ld a,_bcout_rows
    cp d
    jp nz,ExportResults_initmatrix  ;if matrix wrong size, reinitialize it
    ld a,_bcout_columns
    cp e
    jp nz,ExportResults_initmatrix  ;ditto

    ;get state status variable (in order to check it)
    ld hl,output_matrix_name
    ld d,1                      ;row 1
    ld e,1                      ;column 1
    ld a,0                      ;read 
    call MatrixAccess           ;op1 <- matrix element
    call ConvOP1                ;DE <- op1
    ld a,e              ;NOTE: not foolproof to tampering, but good enough
    cp 0
    jp nz,ExportResults_freshdataerror

ExportResults_zeromatrix:
    ;zero out the matrix
    ld hl,output_matrix_name
    call MatrixZero

    ;set state status variable to indicate fresh data
    ld a,1
    call _setXXop1              ;op1 <- A
    ld hl,output_matrix_name
    ld d,1                      ;row 1
    ld e,1                      ;column 1
    ld a,1                      ;write 
    call MatrixAccess           ;matrix element <- op1

    ;set mill number field
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_mill_num
    add hl,bc
    ld a,(hl)                   ;A <- mill number
    call _setXXop1              ;op1 <- A
    ld hl,output_matrix_name
    ld d,1                      ;row 1
    ld e,2                      ;column 2
    ld a,1                      ;write
    call MatrixAccess           ;matrix element <- op1

    ;fill in butt diameter element
    ld a,(log_dia)
    call _setXXop1              ;op1 <- A
    ld hl,output_matrix_name
    ld d,1                      ;row 1
    ld e,3                      ;column 1
    ld a,1                      ;write 
    call MatrixAccess           ;matrix element <- op1

    ;fill in data for row 2
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_lengths
    add hl,bc
    ld b,h
    ld c,l                      ;BC <- array address
    ld e,6                      ;array length
    ld a,0                      ;databyte array
    ld hl,output_matrix_name
    ld d,2                      ;matrix row 2
    call ArrayToMatRow

    ;fill in data for row 3
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_v
    add hl,bc
    ld b,h
    ld c,l                      ;BC <- array address
    ld e,6                      ;array length
    ld a,1                      ;dataword array
    ld hl,output_matrix_name
    ld d,3                      ;matrix row 3
    call ArrayToMatRow

    ;fill in data for row 4
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_p
    add hl,bc
    ld b,h
    ld c,l                      ;BC <- array address
    ld e,6                      ;array length
    ld a,1                      ;dataword array
    ld hl,output_matrix_name
    ld d,4                      ;matrix row 4
    call ArrayToMatRow

    ;fill in data for row 5
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_td
    add hl,bc
    ld b,h
    ld c,l                      ;BC <- array address
    ld e,6                      ;array length
    ld a,0                      ;databyte array
    ld hl,output_matrix_name
    ld d,5                      ;matrix row 5
    call ArrayToMatRow

    ;fill in data for row 6
    pop hl                      ;HL <- initial data address
    push hl                     ;save HL for later
    ld bc,_result_offset_LCV_index
    add hl,bc
    ld b,h
    ld c,l                      ;BC <- array address
    ld e,6                      ;array length
    ld a,0                      ;databyte array
    ld hl,output_matrix_name
    ld d,6                      ;matrix row 6
    call ArrayToMatRow

    ;return
    pop hl
    call ResetCarryFlag
    ret
ExportResults_initmatrix:       ;matrix is nonexistant, initialize it
    ld hl,output_matrix_name
    ld d,_bcout_rows            ;rows
    ld e,_bcout_columns         ;columns
    ld a,2                      ;create
    call MatrixAccess           
    jp ExportResults_zeromatrix
ExportResults_freshdataerror:   ;previous data was not read in by TIBASIC 
    pop hl                      ;   program, this signifies a problem, data
    call SetCarryFlag           ;   should be "stale" not fresh

    ret                         ;return

