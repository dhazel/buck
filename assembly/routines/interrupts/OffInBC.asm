

;============================================================
; OffInBC -- Installs and removes the user off routine that catches a
;           "turn off" during program execution.  
;  input:   A == 1  if interrupt is to be installed regular (clears screen)
;           A == 2  if interrupt is to be installed for a handoff routine
;                       (prints warning)
;                   else interrupt is removed
;  output:  manages the interrupt's state
;  affects: assume everything
;  total: 218b
;  tested: yes
;============================================================
OffInBC:
    ;turn off the interrupt so it is not called when partially installed
    res alt_off,(iy + exceptionflg)     

    ;return after turning off interrupt if it is not to be installed
    cp 1
    jp z,OffInBC_installregular
    cp 2
    jp z,OffInBC_installhandoff
    ret

OffInBC_installregular:
    ld a,0
    ld (OffInBC_control1),a
    jp OffInBC_install
OffInBC_installhandoff:
    ld a,1
    ld (OffInBC_control1),a
OffInBC_install:
    ;copy our code to the interrupt calling area
    ld hl,OffInBC_start
    ld de,_alt_off_exec
    ld bc,OffInBC_end - OffInBC_start 
    ldir 

    ;set up checksum byte 
    ld a,(_alt_off_exec)  
    ld hl,_alt_off_chksum + ($28 * 1) 
    add a,(hl) 
    ld hl,_alt_off_chksum + ($28 * 2) 
    add a,(hl) 
    ld hl,_alt_off_chksum + ($28 * 3) 
    add a,(hl) 
    ld hl,_alt_off_chksum + ($28 * 4) 
    add a,(hl) 
    ld hl,_alt_off_chksum + ($28 * 5) 
    add a,(hl) 
    ld (_alt_off_chksum),a 

    ;turn the interrupt on 
    set alt_off,(iy + exceptionflg)
             
    ret
OffInBC_start:
    jr OffInBC_dataend
OffInBC_control1:
OffInBC_control2 equ $ - OffInBC_start + _alt_off_exec 
    .db 0   ;0 == regular; 1 == handoff
OffInBC_text equ $ - OffInBC_start + _alt_off_exec 
    .db "Your changes are not  saved!!",0
OffInBC_text2 equ $ - OffInBC_start + _alt_off_exec 
    .db "Turning off....",0
OffInBC_text3 equ $ - OffInBC_start + _alt_off_exec 
    .db "  < press any key >",0
OffInBC_dataend:
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

    ;check for what we are doing
    ld a,(OffInBC_control2)
    cp 0
    jr z,OffInBC_regular

    ;present user with bigmessage warning
    call _clrLCD
    call _homeup
    ld hl,OffInBC_text
    call _puts
    call _newline
    call _newline
    ld hl,OffInBC_text2
    call _puts
    call _newline
    call _newline
    ld hl,OffInBC_text3
    call _puts
    call _getkey
OffInBC_regular:
    call _clrScrn
    call _homeup

    ;recall the original page
    pop af         ;pop the initial ROM page 
    out (5),a      

    ;turn the interrupt off
    res alt_off,(iy + exceptionflg)     

    pop ix          ;get all these back
    pop hl
    pop de
    pop bc
    pop af 
    ret 
OffInBC_end:


