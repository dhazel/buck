

;===============================================================================
; MatrixAccess -- can create matrices and write and retrieve matrix elements 
;           based on matrix variable name and desired row and column 
;  input:   HL == points to name of matrix excluding type byte (lngth initlzd)
;           D  == desired row (starting from 1)
;           E  == desired column (starting from 1)
;           A  -  if A == 1 then write the element
;                 else if A == 2 then create matrix variable (delete old one)
;                 else if A == 3 then output the matrix dimensions to DE
;                 else get the element
;           * if A == 1; then OP1 == number to copy to matrix element
;  output:  OP1 == matrix element (not true when A at input is 2 or 3)
;           zero flag set if variable does not exist, otherwise reset
;           carry flag set if requested element is out of bounds, otw reset
;               - carry flag also set if 255 element error occurs (see below)
;           * if A == 3 at input, then D == rows and E == columns of matrix
;  affects: assume everything
;  total: 201b
;  tested: yes
;   NOTE:   - errors out if total elements is greater than 255
;           - not optimized for speed or size! using file descriptors rather
;               than repetitively searching the VAT tables for variable 
;               addresses would be very nice, among other things
;           - only works for simple floating-point matrices, do not try and 
;               use complex or imaginary numbers! it may break!!
;           - when a matrix is created it's contents are undefined!
;               - may be good to fill with zeros as a precaution
;           - this routine was not designed for as much functionality as it has,
;               the code has become hairy
;===============================================================================
MatrixAccess:
    push de             ;put DE into BC
    pop bc

    push af             ;save desired operation designation (get or write)
    push bc             ;save row/col wanted
    push af             ;save desired operation designation (get or write)
    push hl             ;save address of matrix name

    ;check for proper inputs (no zero requests!)
    cp 3                ;if just requesting row/col data, then don't check BC
    jp MatrixAccess_noBCcheck
    ld a,0              
    cp b
    jp z,MatrixAccess_outofbounds
    cp c
    jp z,MatrixAccess_outofbounds
MatrixAccess_noBCcheck:
    ;save OP1 for later
    call _ex_op1_op2    ;put OP1 in OP2 for now

    ;access the TIOS variable
    pop hl              ;pointer to matrix name
    dec hl              ;copy anything before string name for type byte
        rst 20h         ;_mov10toOP1
        rst 10h         ;_findsym
                        ;bde = variable data start
    jp c,MatrixAccess_nomatrix

    ;check for matrix create commands
    pop af              ;recall A
    cp 2
    jp z,MatrixAccess_matrix_precreate
    push af

    ;recall OP1
    push bc
    push de
    call _ex_op1_op2    ;switch OP2 back into OP1
    pop de
    pop bc

    ;get the matrix dimension data (stored in first two bytes)
    call _ex_ahl_bde
    call _get_word_ahl  ;matrix dimensions (D == rows, E == columns)
    pop ix              ;get command variable off stack for now
    pop bc              ;pop back row/col desired

    ;check if we are requesting an existant element
    push af
    push hl

    ;do we check for existant element, or do we output the matrix dimensions?
    push ix             ;get command variable back into A
    pop af
    cp 3
    jp nz,MatrixAccess_boundscheck

    ;dimension output command was given
    pop hl              ;pop these off the stack
    pop af
    pop af
    jp MatrixAccess_return  ;return ;DE holds row/col data
MatrixAccess_boundscheck:   ;normal operation, check for existant element
    ld a,d
    cp b
    jp c,MatrixAccess_outofbounds
    ld a,e
    cp c
    jp c,MatrixAccess_outofbounds
    
    ;locate the element address
    dec b               ;index request from zero for calculations
    dec c
    ld h,b              ;multiply row by total columns to get offset
    call Mult8Bit       ;NOTE: this breaks with total elements > 255
    ld a,h                  ;check for breakage
    cp 0
    jp nz,MatrixAccess_outofbounds
    ld a,l                  
    add a,c             ;add column to the offset to get element location
    cp 0                ;if element location is zero, no need to loop
    jp z,MatrixAccess_almostcopyelement
    ld e,a              ;multiply by element length to get byte location
    ld d,0
    ld a,10             ;each element is 10 bytes long
    call Mult8~16Bit
    ld c,l              ;iterate on BC
    ld b,h
    pop hl              ;pop out the absolute address
    pop af
    push bc             
MatrixAccess_loop:      ;loop up to element location
    call _inc_ptr_ahl   ;increment the absolute address
    pop bc
    dec bc
    ld d,a              ;save A
    ld a,c
    cp 0
    jp nz,MatrixAccess_loop_cont
    ld a,b
    cp 0
    jp nz,MatrixAccess_loop_cont
    ld a,d              ;recall A
    jp MatrixAccess_choosecopyelement
MatrixAccess_loop_cont:
    ld a,d              ;recall A
    push bc
    jp MatrixAccess_loop
MatrixAccess_almostcopyelement:
    pop hl              ;pop out the absolute address
    pop af
MatrixAccess_choosecopyelement:
    ;determine whether we are getting or writing
    ld d,a              ;save A
    pop af              ;retrieve the operation designator
    cp 1
    ld a,d              ;retrieve A
    jp z,MatrixAccess_copyelementwrite
MatrixAccess_copyelementget:
    ;copy the element into OP1
    call _abs_mov10toop1
    jp MatrixAccess_return
MatrixAccess_copyelementwrite:
    ;copy the element from OP1
    call _abs_movfrop1_set_d
MatrixAccess_return:
    ;finish up and return, status = good
    call ResetZeroFlag  ;reset the necessary flags
    call ResetCarryFlag
    ret
MatrixAccess_outofbounds: ;requested element is out of the matrix bounds
    pop hl              ;get these off the stack
    pop af
    pop af
    ;handle the error ;set carry flag 
    call ResetZeroFlag
    call SetCarryFlag
    ret
MatrixAccess_nomatrix:  ;requested variable does not exist
    pop af              ;get these off the stack
    pop hl
    pop af

    ;check for matrix create command
    cp 2
    jp z,MatrixAccess_nomatrix_create

    ;handle the error ;set zero flag ;return
    call ResetCarryFlag
    call SetZeroFlag
    ret
MatrixAccess_matrix_precreate:
    call _delvar        ;delete variable
    pop hl
    pop af
MatrixAccess_nomatrix_create:
    ;create the matrix
    call _creatermat 

    ;return peacefully
    jp MatrixAccess_return

