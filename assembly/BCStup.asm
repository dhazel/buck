

;* BCStup -- The setup helper program. This handles program setup and 
;*              configuration.
;*******************************************************************************

#include bc_includes.asm

.org _asm_exec_ram ;PROGRAM START
;
; BCStup -- main execution block
;   tested: yes
;   NOTE: these comments are here for compliance with the dependency parser
;
    jp BCStup

#include bc_data.asm
#include BCStup.asm.inc             ;autogenerated include file

BCStup:
#ifndef DEBUG
    ;check for tampering/piracy
    call TamperChk
#endif

    ;call BCSetup
    call BCSetup

    ;write data back over to BC
    ld hl,pname_MainBuckingCalculator ;NOTE: only if data blocks are compatable
                                      ;   can you make this work with multiple 
    call copyover_data                ;   versions of BC!

    ;return
    ret


;============================================================
; BCSetup -- displays the bucking setup screen and hands
;               execution to the user-specified routine
;  input: user keypress input
;  output: program branching
;  affects: assume everything
;  total: 1046b
;  tested: no
;   NOTE: This routine is made to be called!
;============================================================
    jp BCSetup ;just in case!
BCSetup_Welcome_text: .db "-- Bucking Setup --",0

;menu data
BCSetup_menu_data:
        .db 5,1,4,"EXIT"
        .db 27,1,6,"PRICES"
        .db 55,1,4,"MILL"
        .db 82,1,4,"CALC"
        .db 109,1,4,"STAT"
BCSetup_drawsetup_menu_data:
        .db 5,1,4,"EXIT"
        .db 28,0,1," "
        .db 57,0,4,"EDIT"
        .db 79,1,6,"PRICES"
        .db 108,1,4,"DONE"

;mill setup
BCSetup_millwelcome_text: .db "Mill:",0
BCSetup_mill_drawsetup: .dw BCSetup_millwelcome_text,mill1_name,mill2_name,mill3_name
BCSetup_millname_text: .db "Name:",0
BCSetup_milldistance_text: .db "Distance:",0
BCSetup_editingmill_text: .db "       EDITING   MILL",0
BCSetup_mill_edit_drawsetup: .dw BCSetup_millwelcome_text,BCSetup_millname_text,BCSetup_milldistance_text,nomessage_text

;calc setup
BCSetup_calcwelcome_text: .db "Calculation Mode:",0
BCSetup_basiccalc_text: .db "Basic",0
BCSetup_usercomparecalc_text: .db "Guess Compare",0
BCSetup_millcomparecalc_text: .db "Mill Compare",0
BCSetup_calc_drawsetup: .dw BCSetup_calcwelcome_text,BCSetup_basiccalc_text,BCSetup_usercomparecalc_text,BCSetup_millcomparecalc_text

;stat setup
BCSetup_statswelcome_text: .db "Statistics:",0
BCSetup_statson_text: .db "ON",0
BCSetup_statsoff_text: .db "OFF",0
BCSetup_stats_drawsetup: .dw BCSetup_statswelcome_text,BCSetup_statsoff_text,BCSetup_statson_text,nomessage_text

BCSetup:
    call _runindicoff           ;turn run indicator off

    call _clrScrn               ;clear screen
    
    call BCSetup_drawheader
    
    ld hl,BCSetup_menu_data
    call menu

BCSetup_getkey:
    call _getkey                ;wait for a keypress
    cp kExit
    jp z,BCSetup_exit         ;jump to program exit
    cp kF1
    jp z,BCSetup_exit         ;jump to program exit
    cp kF2
    jp z,BCSetup_LP           ;prep to call BCLP
    cp kF3
    jp z,BCSetup_mill
    cp kF4
    jp z,BCSetup_calc
    cp kF5
    jp z,BCSetup_stat
    jp BCSetup_getkey
BCSetup_LP:
    call Handoff_BCLP2
    jp BCSetup                ;jump back to BCSetup
BCSetup_mill:
    call BCSetup_drawheader
    ld ix,BCSetup_mill_drawsetup
    call BCSetup_drawsetup
    
    ;display the menu
    ld hl,BCSetup_drawsetup_menu_data + 12
    ld (hl),1
    ld hl,BCSetup_drawsetup_menu_data
    call menu
    ld hl,BCSetup_drawsetup_menu_data + 12
    ld (hl),0

    ld hl,currentmill_number
    call BCSetup_putarrow
BCSetup_mill_getkey:
    call _getkey                ;wait for a keypress
    cp kExit
    jp z,BCSetup_mill_return
    cp kF1
    jp z,BCSetup_mill_return
    cp kF5
    jp z,BCSetup_mill_return
    cp kF3
    jp z,BCSetup_mill_edit
    cp kF4
    jp z,BCSetup_mill_prices
    cp kUp
    jp z,BCSetup_mill_changemill_up
    cp kDown
    jp z,BCSetup_mill_changemill_down
    jp BCSetup_mill_getkey
BCSetup_mill_prices:
    call Handoff_BCLP2
    jp BCSetup_mill
BCSetup_mill_changemill_up:
    ;check for the top
    ld a,(mill_number)
    cp 0
    jp z,BCSetup_mill_getkey

    ;update current mill
    ld hl,mill_number
    dec (hl)
    
    ;put the arrow
    call BCSetup_putarrow

    ;update the mill data
    call SwitchMill

    ;return to getkey
    jp BCSetup_mill_getkey
BCSetup_mill_changemill_down:
    ;check for the bottom
    ld a,(mill_number)
    cp 2
    jp z,BCSetup_mill_getkey

    ;update current mill
    ld hl,mill_number
    inc (hl)

    ;put the arrow
    call BCSetup_putarrow

    ;update the mill data
    call SwitchMill

    ;return to getkey
    jp BCSetup_mill_getkey
BCSetup_mill_edit:
    call BCSetup_drawheader

    ;draw setup module screen
    ld ix,BCSetup_mill_edit_drawsetup
    call BCSetup_drawsetup
    ld hl,BCSetup_editingmill_text
    call menuhighmessage
    ld hl,BCSetup_drawsetup_menu_data
    call menu

    ;print mill distance
        ld a,4
    ld (_curRow),a
        ld a,11
    ld (_curCol),a
    ld a,(mill_distance)
    ld l,a
    ld h,0
    xor a
    call _dispAHL

    ;print mill name
        ld a,3
    ld (_curRow),a
        ld a,8
    ld (_curCol),a
    ld hl,mill_name
    call _puts

    ;set cursor and write mode
        ld a,3
    ld (_curRow),a
        ld a,8
    ld (_curCol),a
    set shiftAlpha,(iy+shiftflags)      ;upper case alpha keys enabled
    set shiftALock,(iy+shiftflags)      ;alpha keys locked in
        ;NOTE -- we work in uppercase, but will save and display in lowercase
BCSetup_mill_edit_getkey:
    call _cursoron              ;turn the flashing cursor on
    call _getkey                ;wait for a keypress
    cp kExit
    jp z,BCSetup_mill_edit_return
    cp kF5
    jp z,BCSetup_mill_edit_return
    cp kF1
    jp z,BCSetup_mill_edit_return
    cp kF4
    jp z,BCSetup_mill_edit_prices
    cp kRight
    jp z,BCSetup_mill_edit_name_right
    cp kLeft
    jp z,BCSetup_mill_edit_name_left
    cp kUp
    jp z,BCSetup_mill_edit_up
    cp kDown
    jp z,BCSetup_mill_edit_down
    cp kSpace
    jp c,BCSetup_mill_edit_getkey
    cp kCapZ + 1
    jp c,BCSetup_mill_edit_name
    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_name:
    ;check for space key, convert keycode to charactercode
    cp kSpace
    jp nz,BCSetup_mill_edit_name_notspace
    ld a,Lspace
    jp BCSetup_mill_edit_name_overnotspace
BCSetup_mill_edit_name_notspace:
    add a,$39
BCSetup_mill_edit_name_overnotspace:
    ;check whether name is full
    ld c,a
    ld a,(_curCol)
    cp 8 + currentmill_number - mill_name - 2
    jp z,BCSetup_mill_edit_getkey

    ;write the character to cursor location in mill_name string
    ld hl,mill_name
    sub 8
    ld b,a
    call ArrayAccess_ne
    ld (hl),c

    call _cursoroff

    ;write the character to the screen
    ld a,c
    call _putc

    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_name_right:
    ;check whether we are at end of name
    ld a,(_curCol)
    cp 8 + currentmill_number - mill_name - 3
    jp z,BCSetup_mill_edit_getkey
    
    
    ;if not at end of name then move right
    call _cursoroff
    ld a,(_curCol)
    inc a
    ld (_curCol),a
    call _cursoron
    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_name_left:
    ;check whether we are at beginning of name
    ld a,(_curCol)
    cp 8 
    jp z,BCSetup_mill_edit_getkey
    
    ;if not at end of name then move left
    call _cursoroff
    ld a,(_curCol)
    dec a
    ld (_curCol),a
    call _cursoron
    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_prices:
    call _cursoroff
    res shiftAlpha,(iy+shiftflags)      ;upper case alpha keys disabled
    res shiftALock,(iy+shiftflags)      ;alpha key lock turned off
    call Handoff_BCLP2
    set shiftAlpha,(iy+shiftflags)      ;upper case alpha keys enabled
    set shiftALock,(iy+shiftflags)      ;alpha key lock turned on
    jp BCSetup_mill_edit
BCSetup_mill_edit_up:
    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_down:
    jp BCSetup_mill_edit_getkey
BCSetup_mill_edit_return:
    call _cursoroff
    res shiftAlpha,(iy+shiftflags)      ;upper case alpha keys disabled
    res shiftALock,(iy+shiftflags)      ;alpha key lock turned off
    call SwitchMill                     ;replicates mill data
    ld a,1                              ;reinit the name variable
    call StatDataInit
    call save_data                      ;save the data
    jp BCSetup_mill
BCSetup_mill_return:
    call save_data
    jp BCSetup                ;return to BCSetup
BCSetup_calc:
    ld ix,BCSetup_calc_drawsetup
    call BCSetup_drawsetup
    
    ;display done menu option
    ld hl,BCSetup_drawsetup_menu_data + 19
    ld (hl),0
    ld hl,BCSetup_drawsetup_menu_data
    call menu
    ld hl,BCSetup_drawsetup_menu_data + 19
    ld (hl),1

    ld hl,calculation_mode
    call BCSetup_putarrow
BCSetup_calc_getkey:
    call _getkey                ;wait for a keypress
    cp kExit
    jp z,BCSetup_calc_return
    cp kF1
    jp z,BCSetup_calc_return
    cp kF5
    jp z,BCSetup_calc_return
    cp kUp
    jp z,BCSetup_calc_changemode_up
    cp kDown
    jp z,BCSetup_calc_changemode_down
    jp BCSetup_calc_getkey
BCSetup_calc_changemode_up:
    ;check for the top
    ld a,(calculation_mode)
    cp 0
    jp z,BCSetup_calc_getkey

    ;update calculation_mode
    ld hl,calculation_mode
    dec (hl)

    ;place the arrow
    call BCSetup_putarrow

    ;return to getkey
    jp BCSetup_calc_getkey
BCSetup_calc_changemode_down:
    ;check for the bottom
    ld a,(calculation_mode)
    cp 2
    jp z,BCSetup_calc_getkey

    ;update calculation_mode
    ld hl,calculation_mode
    inc (hl)
    
    ;put the arrow
    call BCSetup_putarrow

    ;return to getkey
    jp BCSetup_calc_getkey
BCSetup_calc_return:
    call save_data
    jp BCSetup                ;return to BCSetup
BCSetup_stat:
    call BCSetup_drawheader

    ;draw setup module screen
    ld ix,BCSetup_stats_drawsetup
    call BCSetup_drawsetup

    ;display done menu option
    ld hl,BCSetup_drawsetup_menu_data + 19
    ld (hl),0
    ld hl,BCSetup_drawsetup_menu_data
    call menu
    ld hl,BCSetup_drawsetup_menu_data + 19
    ld (hl),1

    ld hl,statistics
    call BCSetup_putarrow
BCSetup_stat_getkey:
    call _getkey                ;wait for a keypress
    cp kExit
    jp z,BCSetup_stat_return
    cp kF1
    jp z,BCSetup_stat_return
    cp kF5
    jp z,BCSetup_stat_return
    cp kUp
    jp z,BCSetup_stat_up
    cp kDown
    jp z,BCSetup_stat_down
    jp BCSetup_stat_getkey
BCSetup_stat_up:
    ;check for the top
    ld a,(statistics)
    cp 0
    jp z,BCSetup_stat_getkey

    ;update statistics setting
    ld hl,statistics
    dec (hl)

    ;place the arrow
    call BCSetup_putarrow

    ;return to getkey
    jp BCSetup_stat_getkey
BCSetup_stat_down:
    ;check for the bottom
    ld a,(statistics)
    cp 1
    jp z,BCSetup_stat_getkey

    ;update calculation_mode
    ld hl,statistics
    inc (hl)
    
    ;put the arrow
    call BCSetup_putarrow

    ;return to getkey
    jp BCSetup_stat_getkey
BCSetup_stat_return:
    call save_data
    jp BCSetup                ;return to BCSetup
BCSetup_exit:
    call _clrScrn               ;clear the screen
    ret                         ;return 

BCSetup_drawsetup: ;draws the screen for the setup modules
    ; input: IX = array of pointers to each text string
    ;           (ie: IX(0)==title IX(1)==option1 IX(2)==option2 IX(3)==option3)
    ; NOTE: best used when followed by an arrow drawing routine to select
    ;           options
    ;
    ld hl,_winTop               ;clear the window area
    ld (hl),1
    call clearwindow
    ld hl,_winTop
    ld (hl),0

        ld a,0                  ;display title
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld l,(ix+0)
    ld h,(ix+1)
    call _puts   

        ld a,2                  ;display option1
    ld (_curCol),a
        ld a,3
    ld (_curRow),a
    ld l,(ix+2)
    ld h,(ix+3)
    call _puts   

        ld a,2                  ;display option2
    ld (_curCol),a
        ld a,4
    ld (_curRow),a
    ld l,(ix+4)
    ld h,(ix+5)
    call _puts   

        ld a,2                  ;display option3
    ld (_curCol),a
        ld a,5
    ld (_curRow),a
    ld l,(ix+6)
    ld h,(ix+7)
    call _puts   

    ret
    
BCSetup_drawheader: ;draws the BCSetup header at the top of the screen
    ; input: none
    ;
        ld a,1                  ;display setup header text 
    ld (_curCol),a
        ld a,0
    ld (_curRow),a
    ld hl,BCSetup_Welcome_text
    call _puts    
    ret

BCSetup_putarrow: ;places a selection arrow on the drawsetup screen
    ; input: HL == pointer to selection number (for arrow location), starting
    ;               from zero
    ;
    push hl

    ;erase previous arrow
        ld a,1                
    ld (_curCol),a
    ld a,Lspace
    call _putc   

    ;draw the arrow
    pop hl
    ld a,(hl)
    add a,3
    ld (_curRow),a
        ld a,1 
    ld (_curCol),a
    ld a,Lstore
    call _putc   

    ret


