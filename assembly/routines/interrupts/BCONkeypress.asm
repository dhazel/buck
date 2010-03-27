

;============================================================
; BCMOREkeypress -- Installs and removes the interrupt that checks for the 
;           [ MORE ] key durring TIOS runtime. Starts BC if [ MORE ] key is 
;           pressed.
;  input:   A == 1  if interrupt is to be installed, else interrupt is removed
;  output:  manages the interrupt's state
;  affects: assume everything
;  total: b (including ret)
;  tested: no incomplete uncounted
;   NOTE: This does not work... crashes the calculator majorly. I need more
;           data on interrupt state when this is called.
;============================================================
BCMOREkeypress:
    ;turn off the interrupt so it is not called when partially installed
    res alt_int,(iy + exceptionflg)     

    ;return after turning off interrupt if it is not to be installed
    cp 1
    ret nz

    ;copy our code to the interrupt calling area
    ld hl,BCMOREkeypress_start
    ld de,_alt_interrupt_exec
    ld bc,BCMOREkeypress_end - BCMOREkeypress_start 
    ldir 

    ;set up checksum byte 
    ld a,(_alt_interrupt_exec)  
    ld hl,_alt_int_chksum + ($28 * 1) 
    add a,(hl) 
    ld hl,_alt_int_chksum + ($28 * 2) 
    add a,(hl) 
    ld hl,_alt_int_chksum + ($28 * 3) 
    add a,(hl) 
    ld hl,_alt_int_chksum + ($28 * 4) 
    add a,(hl) 
    ld hl,_alt_int_chksum + ($28 * 5) 
    add a,(hl) 
    ld (_alt_int_chksum),a 

    ;turn the interrupt on 
    set alt_int,(iy + exceptionflg)
             
    ret
BCMOREkeypress_start:
    jr BCMOREkeypress_dataend ;jump over our resident data
pname_BUCK: .db 4,"BUCK"
BCMOREkeypress_dataend:
    push af              ;to be safe, lets push them all
    push bc
    push de
    push hl
    push ix

    ;check for alpha mode
    bit shiftAlpha,(iy + shiftflags)
    jr z,BCMOREkeypress_return

    ;poll the keyport for the [ MORE ] key
    ld a,%10111111      ;bitmask for the [ MORE ] key's row
    out (1),a           ;the keyport is port 1
    nop                 ;wait to get a result back
    nop
    in a,(1)            ;get the result
    bit 7,a             ;[ MORE ]'s position
    jr nz,BCMOREkeypress_return

    ;turn off the interrupt
    res alt_int,(iy + exceptionflg)

    ;page in the jump table ROM page
    in a,(5)       ;get the current ROM page 
    push af        ;push the ROM page 
    ld a,$d        ;set the new ROM page to the jump table 
    out (5),a 

        ;NOTE: check for OP register trouble!
    ;check for existance of BC
    ld hl,pname_BUCK-1    ;copy anything before string name 
                                            ; for type byte
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym to see if variable
                                            ; exists
    ;if not present, display bigmessage and return
    jp c,BCMOREkeypress_return

    ;call BC 
    call _exec_basic             ;exec basic program named in op1

    ;recall the original page
    pop af         ;pop the initial ROM page 
    out (5),a      

BCMOREkeypress_return:
    pop ix          ;get all these back
    pop hl
    pop de
    pop bc
    pop af 
    ret 
BCMOREkeypress_end:


