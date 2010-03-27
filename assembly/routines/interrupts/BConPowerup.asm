

;============================================================
; BConPowerup -- Installs and removes the interrupt that runs every time the 
;           calculator starts up. This interrupt will start BC at poweron.
;  input:   A == 1  if interrupt is to be installed, else interrupt is removed
;  output:  manages the interrupt's state
;  affects: assume everything
;  total: b (including ret)
;  tested: no incomplete uncounted
;   NOTE: This does not work as far as I can tell. I need more data on the 
;           system state when the user-on routine is called.
;============================================================
BConPowerup:
    ;turn off the interrupt so it is not called when partially installed
    res alt_on,(iy + exceptionflg)     

    ;return after turning off interrupt if it is not to be installed
    cp 1
    ret nz

    ;copy our code to the interrupt calling area
    ld hl,BConPowerup_start
    ld de,_alt_on_exec
    ld bc,BConPowerup_end - BConPowerup_start 
    ldir 

    ;set up checksum byte 
    ld a,(_alt_on_exec)  
    ld hl,_alt_on_chksum + ($28 * 1) 
    add a,(hl) 
    ld hl,_alt_on_chksum + ($28 * 2) 
    add a,(hl) 
    ld hl,_alt_on_chksum + ($28 * 3) 
    add a,(hl) 
    ld hl,_alt_on_chksum + ($28 * 4) 
    add a,(hl) 
    ld hl,_alt_on_chksum + ($28 * 5) 
    add a,(hl) 
    ld (_alt_on_chksum),a 

    ;turn the interrupt on 
    set alt_on,(iy + exceptionflg)
             
    ret
BConPowerup_start:
    jr BConPowerup_dataend ;jump over our resident data
pname_BUCK: .db 4,"BUCK"
BConPowerup_dataend:
    push af              ;to be safe, lets push them all
    push bc
    push de
    push hl
    push ix

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
    jp c,BConPowerup_return

    ;call BC 
    call _exec_basic             ;exec basic program named in op1

    ;recall the original page
    pop af         ;pop the initial ROM page 
    out (5),a      

BConPowerup_return:
    pop ix          ;get all these back
    pop hl
    pop de
    pop bc
    pop af 
    ret 
BConPowerup_end:


