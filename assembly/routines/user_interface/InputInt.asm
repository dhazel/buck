

;==============================================================================
; InputInt -- accepts an integer input from the keypad
;  input:   HL  = the maximum limit for the input number
;           A   = initial keypress input (if desired), else load with non-number
;  output:  DE  <- number typed
;           carry flag <- set if the number is too big, reset if number is good
;           zero flag <- set if output is to be ignored, user did nothing
;           number is printed to the screen as it is typed
;  affects: assume everything 
;           * does not affect the OP registers 
;  total: 217b (including ret)
;  tested: yes
;   NOTE:   If max number is reached InputInt writes zero to DE, sets the carry
;               and zero flags, and returns
;           If reset, the zero flag indicates that the user did something and 
;               DE is legitimate; else, DE is illigitimate
;==============================================================================
InputInt: 
    ;set DE to zero
    ld de,0

    ;check for initial keypress input
    cp k0
    jp c,InputInt_getkey
    cp k9+1
    jp c,InputInt_number
InputInt_getkey:
    push de                     ;haven't tested it, but these may be necessary
    push hl
    call _cursoron              ;turn blinking cursor on
    call _getkey                ;wait for a keypress
    pop hl
    pop de
    cp kEnter                   ;is a=kEnter
    jp z,InputInt_enter           ;it is...jump...
    cp kExit
    jp z,InputInt_enter
    cp kUp
    jp z,InputInt_enter
    cp kDown
    jp z,InputInt_enter
    cp kLeft
    jp z,InputInt_enter
    cp kRight
    jp z,InputInt_enter
    cp kClear
    jp z,InputInt_clear
    cp kDel
    jp z,InputInt_clear
    cp k0
    jp c,InputInt_getkey
    cp k9+1
    jp c,InputInt_number
    jp InputInt_getkey
InputInt_enter:
    push de
    call _cursoroff
    pop de

    ;check for zero in DE
    call InputInt_DE_checkzero

    ;reset the carry flag
    push af
    pop bc
    res carryFlag,c
    push bc
    pop af

    ;return
    ret
InputInt_clear:
    push de
    call _cursoroff
    pop de

    ;zero DE
    ld de,0

    ;reset the carry and zero flags
    res carryFlag,c
    res zeroFlag,c
    push bc
    pop af

    ;return
    ret 
InputInt_number:
    ld c,a                      ;c <- keycode 
    ;check for zero, if zero with zero current value then return to getkey
    call InputInt_DE_checkzero
    jp nz,InputInt_number_nonzero

    ld a,c
    cp k0
    jp z,InputInt_getkey
InputInt_number_nonzero: 
    ;prep and check number variable load
    ld a,c  ;a <- keycode
    sub k0
    ld c,a  ;save for later (holds number pressed)
    push hl ;save for later (holds max number)
    ld a,10                     ;bump up previous number one place-value
    call Mult8~16Bit            ;hl = de * a
    ;is number within limits?
    pop de                      ;DE <- max number
    call InputInt_checkfortoobig    ;is HL > DE ??
    jp c,InputInt_number_toobig
    ;load number to variable
    ;(C holds number pressed)
    ;(HL holds current variable value)
    ld b,0                    ;for clarity! (B is already zero from Mult8~16Bit)
    add hl,bc                   ;add current number to current variable value
    ;is number still within algorithm limits?
    call InputInt_checkfortoobig    ;is HL > DE ??
    jp c,InputInt_number_toobig ;number is now too big
    push de                     ;DE == max number
    push hl                     ;HL == result number
    
    ;print number to screen
    ld a,c                      ;retrieve our number    
    add a,L0                    ;convert number to its display value
    call _putc                  ;print number to screen

    ;load DE with result number
    pop de
    ;load HL with max number
    pop hl
   
    ;return to getkey
    jp InputInt_getkey
InputInt_number_toobig:           ;number is too big!
    push de
    call _cursoroff
    pop de

    ;zero DE
    ld de,0

    ;set carry and zero flags
    set carryFlag,c
    set zeroFlag,c
    push bc
    pop af

    ;return
    ret 

InputInt_DE_checkzero: ;checks for zeroed DE
    ; inputs:   DE
    ; outputs:  zero flag <- set if DE is zero
    ; affects:  B <- destroyed
    ;           A <- 0
    ;           
    ld b,0
    ld a,0
    cp d
    jp z,InputInt_DE_checkzero_zerobyte1
    ld b,1
InputInt_DE_checkzero_zerobyte1:
    cp e
    jp z,InputInt_DE_checkzero_zerobyte2
    ld b,1
InputInt_DE_checkzero_zerobyte2:
    cp b
    ret

InputInt_checkfortoobig: ; Checks for HL greater than DE
    ; inputs:   DE, HL
    ; outputs:  carry flag is set if HL is greater than DE
    ; affects:  A <- destroyed
    ;   NOTE: assumes that DE and HL are both big-endian
    ;
    push bc
    ld a,d
    cp h
    jp c,InputInt_checkfortoobig_returngreater
    jp nz,InputInt_checkfortoobig_return
    ld a,e
    cp l
    jp c,InputInt_checkfortoobig_returngreater
InputInt_checkfortoobig_return:
    res carryFlag,c
    push bc
    pop af
    pop bc
    ret
InputInt_checkfortoobig_returngreater:
    set carryFlag,c
    push bc
    pop af
    pop bc
    ret

