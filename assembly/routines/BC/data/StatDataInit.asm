

;===============================================================================
; StatDataInit -- initializes the statistics matrices (one for each mill), and
;               fills the first row of the current mill matrix with the LCV
;               elements, clears all data in the current mill statistics matrix
;  input:   LCV - the Length Choice Vector, all available log lengths
;           LCV_size - the size of the LCV (starting from 0)
;           currentmill_number - the number of the current mill
;           if  A == 1, then initialize current mill name variable
;            else, initialize current mill matrix
;  output:  - if any stat data matrices are missing, they are created
;           - if initialized, the current mill matrix is cleared and first row 
;               is filled with the LCV elements
;           - if initialized, the current mill name variable is overwritten
;  affects: assume everything
;  total: 158b
;  tested: no 
;===============================================================================
StatDataInit:
    push af                     ;A == command variable
    call _runindicon

    ;check for existance of stat data matrices and initialize
    ld hl,mill1_matrix_name
    push hl
    ld a,3                      ;dimensions
    call MatrixAccess
    pop hl
    push af
    call z,StatDataInit_initmill
    pop af
    call nz,StatDataInit_checkdims
StatDataInit_checkmill2:
    ld hl,mill2_matrix_name
    push hl
    ld a,3                      ;dimensions
    call MatrixAccess
    pop hl
    push af
    call z,StatDataInit_initmill
    pop af
    call nz,StatDataInit_checkdims
StatDataInit_checkmill3:
    ld hl,mill3_matrix_name
    push hl
    ld a,3                      ;dimensions
    call MatrixAccess
    pop hl
    push af
    call z,StatDataInit_initmill
    pop af
    call nz,StatDataInit_checkdims
StatDataInit_checkmill4:
    ld hl,millcopy_matrix_name
    push hl
    ld a,3                      ;dimensions
    call MatrixAccess
    pop hl
    push af
    call z,StatDataInit_initmill
    pop af
    call nz,StatDataInit_checkdims
    jp StatDataInit_check1over
StatDataInit_checkdims: ;callable section ;check dimensions
    ; input: D == rows
    ;        E == columns
        ld a,d
        cp _statdata_rows
        jp c,StatDataInit_initmill
        ld a,e
        cp _statdata_columns
        jp c,StatDataInit_initmill
        ret
StatDataInit_initmill:  ;callable section ;initialize the mill matrix
    ; input: HL -- pointer to mill matrix name
        push hl
        call ErrStatDataMissing
        pop hl                      ;mill stat data matrix name
        ld d,_statdata_rows         ;rows
        ld e,_statdata_columns      ;columns
        ld a,2                      ;create
        push hl
        call MatrixAccess
        pop hl                      ;mill stat data matrix name
        push hl
        call MatrixZero             ;fill with zeros
        call _op1set1               ;OP1 <- reset price-skew-factor
        pop hl                      ;mill stat data matrix name
        ld d,_statdata_rows         ;last row
        ld e,8                      ;column 8
        ld a,1                      ;write
        call MatrixAccess
        ret
StatDataInit_check1over:

    ;make sure that the mill names are all loaded
    ld hl,mill1_name_var        ;TIOS variable name
    ld de,mill1_name            ;string data to store in variable
    ld a,0                      ;default operation, do nothing if string present
    call StringCreate           ;create the string variable
    ld hl,mill2_name_var
    ld de,mill2_name
    ld a,0
    call StringCreate
    ld hl,mill3_name_var
    ld de,mill3_name
    ld a,0
    call StringCreate
    ld hl,millcopy_name_var
    ld de,mill_fill_name
    ld a,0
    call StringCreate

    ;determine current mill matrix name
    ld a,(currentmill_number)
    cp 0
    jp nz,StatDataInit_currentmillcheck1
    ld bc,mill1_matrix_name
    ld de,mill1_name
    ld hl,mill1_name_var
StatDataInit_currentmillcheck1:
    cp 1
    jp nz,StatDataInit_currentmillcheck2
    ld bc,mill2_matrix_name
    ld de,mill2_name
    ld hl,mill2_name_var
StatDataInit_currentmillcheck2:
    cp 2
    jp nz,StatDataInit_currentmillcheck_end
    ld bc,mill3_matrix_name
    ld de,mill3_name
    ld hl,mill3_name_var
StatDataInit_currentmillcheck_end:
    pop af              ;A == command variable
    push bc             ;mill matrix name

    ;check to update the mill name string in TIOS
    cp 1 
    jp nz,StatDataInit_nonameinit
    ld a,1              ;force overwrite of current string variable
    call StringCreate   ;create the string
    pop hl              ;get this off the stack
    ;reset the error display status
    ld a,0
    ld (errStatDataMissing_displayed),a
    ;return
    ld a,0
    ld (errStatDataMissing_displayed),a
    call _runindicoff
    ret
StatDataInit_nonameinit:
    ;generic mill matrix basic initialization
    pop hl              ;mill matrix name
    push hl
    ld a,1
    ld (errStatDataMissing_displayed),a
    call StatDataInit_initmill

    ;fill current mill matrix first row with LCV elements
    pop hl                  ;mill matrix name
    push hl
    ld bc,LCV               ;data array
    ld d,1                  ;matrix row number
    ld a,(LCV_size)         ;length of data array
    inc a                   ;   index from 1
    ld e,a
    ld a,0                  ;databyte array
    call ArrayToMatRow  

    ;load in the mill's volume constraint percentage value
    ld a,(vol_constraint_percent);A <- volume constraint percentage
    call _setXXop1              ;OP1 <- volume constraint percentage
    pop hl                      ;mill stat data matrix name
    push hl
    ld d,_statdata_rows         ;last row
    ld e,9                      ;column 9
    ld a,1                      ;write
    call MatrixAccess

    ;fill the second-to-last row with the volume constraint identifiers
    pop hl                  ;mill matrix name
    ld bc,vol_constrain     ;data array
    ld d,6                  ;row 6
    ld a,(LCV_size)         ;length of data array
    inc a                   ;   index from 1
    ld e,a
    ld a,0                  ;databyte array
    call ArrayToMatRow

    ;return
    ld a,0
    ld (errStatDataMissing_displayed),a
    call _runindicoff
    ret


   
;============================================================
; ErrStatDataMissing -- called when StatDataInit determines that statistics
;                   data storage in TIOS is missing, data storage space is then
;                   re-created
;  total: 99b
;  tested: no
;============================================================
errStatDataMissing_text: .db "Detected missing      statistics storage   space!  Recreating   it.... Some stat     data has likely      been lost.",0 
errStatDataMissing_bigmessage: .dw errStatDataMissing_text,okay_text,okay_text
errStatDataMissing_displayed: .db 0  ;let's not display message more than once
ErrStatDataMissing: ;if this happens print message and offer two "okay" options
    ;check whether message has already been displayed
    ld a,(errStatDataMissing_displayed)
    cp 1
    jp z,ErrStatDataMissing_skipdisplay
    ld a,1
    ld (errStatDataMissing_displayed),a

    ;print message to screen
    ld ix,errStatDataMissing_bigmessage
    call bigmessage
    call _getkey
ErrStatDataMissing_skipdisplay:
    call workingmessage
    ret

