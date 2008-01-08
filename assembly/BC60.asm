;# TASM Z80 ASM

;FUTURE notes:
;   - might look at using more push/pops for storing Li[s] rather than calling 
;       ArrayAccess
;   - to increase speed, could ditch ArrayAccess routine and just treat all 
;       data as one big array with hard offsets to each section
;   - rather than using (and tediously copying) p,p1,p2,v,v1,v2,td,td1, and td2 
;       arrays, could just track sums of p and v, and could drop the td's 
;       altogether, could offer the option to do that based on statistics 
;       enabled/disabled variable
;   - could extend for use as a timber cruising tool
;       - data collector and compiler
;       - instant cruise results
;       - time-laps stand growth and price estimates??
;   - after cruising, could be used to determine the best mill for the timber 
;       sale
;   - can optimal buck lengths be computed for standing timber??
;       - possibly, using a system similar to the tariff numbers
;       - is this economical for a land-owner/bucker and/or a timber cruiser??
;
;GENERAL notes:
;   - Two-byte registers (eg: hl,de,...) are operated as big endian, as opposed 
;       to the  resident memory which is little endian.
;   - Loading memory with the data-word assembler directive (eg: .dw) causes the
;       memory to  be loaded in little endian byte order.
;   - Modifying the IY register can easily cause massive calculator crashes. IY 
;       is used by the system to hold the beginning address of the TI-OS System 
;       Flags table, only  modify it if you know what you are doing!  
;           (_flags =$c3e5)
               
;#define DEBUG
#include bc_includes.asm



.org _asm_exec_ram ;PROGRAM START
;
; BC -- main Bucking Calculator execution block
;   NOTE: these comments are here for compliance with the dependency parser
;
    jp BC_start

#include bc_data.asm

BC_start:
#ifndef DEBUG
    ;check for tampering/piracy
    call TamperChk
#endif
    
    ;make sure that stat data variables exist in TIOS
    ld a,1              ;re-initialize current mill name variable only
    call StatDataInit   ;this will check all stat data variables
    call SwitchMill     ;this will check and fully initialize the current mill
                        ; matrix variable

    ;load initial FinDisplay data variables
    ld hl,FinDisplay3_basic_display
    ld (FinDisplay_data_pointer),hl

    ;jump to the start screen
    jp BCStart

;
; BC_millcompare_calculate -- the millcompare calculation mode block
;   NOTE: these comments are here for compliance with the dependency parser
;
BC_millcompare_calculate:
    ;save current_mill settings (for reload when done)
    ld a,(currentmill_number)
    push af

    ;switch to mill1
    ld a,0
    ld (mill_number),a
    call SwitchMill

    ;run buck algorithm
    call ResetVolatileData
    call ClearErrors        ;clear all error handler logs
    call BuckInput          ;get user inputs and load variables
    call Buck

    ;save mill1 results
    ld hl,firstchoice_result_vars
    ld de,mill1_result_vars
    ld bc,secondchoice_result_vars - firstchoice_result_vars
    ldir

    ;switch to mill2
    ld a,1
    ld (mill_number),a
    call SwitchMill

    ;run buck algorithm
    call ResetVolatileData
    call Buck
    
    ;save mill2 results
    ld hl,firstchoice_result_vars
    ld de,mill2_result_vars
    ld bc,secondchoice_result_vars - firstchoice_result_vars
    ldir

    ;switch to mill3
    ld a,2
    ld (mill_number),a
    call SwitchMill

    ;run buck algorithm
    call ResetVolatileData
    call Buck

    ;reload current_mill settings and data
    pop af
    ld (mill_number),a
    call SwitchMill

    ;display all results
    ld hl,FinDisplay3_millcompare_display
    ld (FinDisplay_data_pointer),hl
    jp FinMenu

    ret
;
; BC_usercompare_calculate -- the usercompare calculation mode block
;   NOTE: these comments are here for compliance with the dependency parser
;
BC_usercompare_calculate:
    ;run Buck
    call ResetVolatileData  ;reset all volatile data
    call ClearErrors    ;clear all error handler logs
    call BuckInput      ;get user inputs and load variables
    call Buck           ;calculate optimal buck lengths

    ;get user guess result column name
    ld hl,guess_text
    ld de,user_guess_result_name
    call _strcpy
    
    ;loop extract user buck lengths and diameters, calculate price for each one
    ld b,0
BC_usercompare_calculate_loop:
    inc b

    ;check for array overrun
    ld hl,$             ;load HL with address of this location
    push hl             ;push HL for use by s_Overrun error routine
    ld a,b
    cp _log_entries + 1
    jp nc,Err_s_Overrun
    pop hl              ;pop HL back, so it's not on the stack

    ;extract and save length
    ld hl,log
    call ArrayAccess_ne
    ld a,(hl)
    cp 0
    jp z,BC_usercompare_calculate_loop_end
    dec hl
    ld c,(hl)
    sub c               ;'log' array elements are summations of total length
    ld c,a              ;a == length

    ld hl,user_l        ;load user_l with length
    call ArrayAccess_ne
    dec hl              ;we want to index from the zero'th element
    ld (hl),c
    push hl             ;for use in the volume routine

    ;extract diameter
    ld hl,log_dia
    call ArrayAccess_ne
    ld d,(hl)           ;for use in the volume routine
    
    ;check diameter against log criteria
    push bc
    push de
    ld hl,LCV           ;HL <- address of LCV
    ld a,(LCV_size)
    ld b,a              ;B <- LCV_size
    ld a,c              ;A <- length
    call FindByte       ;find the corresponding length element in the LCV
    jp z,BC_usercompare_calculate_loop_skip ;if not found
    ld b,d              ;B <- index
    pop de
    push de
    call CriteriaPassFail ;do we pass the criteria test??
    jp nc,BC_usercompare_calculate_loop_overskip
BC_usercompare_calculate_loop_skip:
    pop de  ;get this off the stack!
    pop bc  ;load B properly
    pop hl  ;get this off the stack!
    jp BC_usercompare_calculate_loop_continuecheck
BC_usercompare_calculate_loop_overskip:
    pop de
    pop bc

    ;calculate volume
    call Volume
    pop bc              ;B iterator, and length - trim (C)
    inc c               ;add trim back into length

    ;save volume
    ld hl,user_v        ;load user_v with volume
    call ArryAccessW_ne
    dec hl              ;we want to start with the first element
    ld (hl),e
    dec hl
    ld (hl),d

    pop de              ;pointer to length (un-needed remnant from Volume)

    push bc             ;save these for later
    ;calculate price
    call Price2standalone
    pop bc              ;get these back

    ;save price
    ld hl,user_p        ;load user_p with price
    call ArryAccessW_ne
    dec hl              ;we want to start with the first element
    ld (hl),e
    dec hl
    ld (hl),d

    ;continue loop??
BC_usercompare_calculate_loop_continuecheck:
    ld a,b              ;are we at the end of the array?
    cp _log_entries
    jp c,BC_usercompare_calculate_loop
BC_usercompare_calculate_loop_end:
    ;sum price and volume arrays
    ld ix,user_p
    call SumWrdArray
    ld (user_sum_p),hl
    ld hl,user_p
    ld ix,user_v
    call SumWrdArray_rel
    ld (user_sum_v),hl

    ;display output
    ld hl,FinDisplay3_usercompare_display
    ld (FinDisplay_data_pointer),hl
    jp FinMenu

    ;call TestPrints            

    ret                 ;just in case!
;
; BC_basic_calculate -- the basic calculation mode block
;   NOTE: these comments are here for compliance with the dependency parser
;
BC_basic_calculate:
    call ResetVolatileData  ;reset all volatile data
    call ClearErrors    ;clear all error handler logs
    call BuckInput      ;get user inputs and load variables
    call Buck           ;calculate optimal buck lengths

    ld hl,FinDisplay3_basic_display
    ld (FinDisplay_data_pointer),hl
    jp FinMenu
    
    ;call TestPrints            

    ret

;===============================================================================
;END OF PROGRAM
;===============================================================================
;===============================================================================





;===============================================================================
;=========[   FUNCTIONS   ]=====================================================
;===============================================================================

#include BC60.asm.inc         ; autogenerated file of dependancies

;===============================================================================

#ifdef DEBUG
    .warning Assembling for debug mode!
#else
    .message Bucking Calculator, Copyright © 2007 by David Hazel
#endif



address_after_prog: $   ;a "$" means "*this* address in memory" ...the address 
                ;that this would be at when this program is at _asm_exec_ram 
                ;in memory with no instructions or data after this, this is a
                ;reference to the byte after your program
                
;#if address_after_prog > $FA70
;    .error Program is too big!
;#endif

.end

