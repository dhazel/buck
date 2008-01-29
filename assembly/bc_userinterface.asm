
;*  User Interface routines used by BC
;****************************************************************

;============================================================
; FinMenu -- controls the final display and menu after 
;               processing a tree, and branches program based 
;               on user input
;  input: user keypress input
;  output: program branching
;  affects: assume everything
;  total:  256b
;  tested: no
;============================================================
FinMenu_menu_data:
        .db 5,1,4,"EXIT"
        .db 27,0,5,"ERROR"
        .db 57,0,5,"C   1"
        .db 83,0,5,"C   2"
        .db 110,0,5,"C   3"

FinMenu:
    call FinDisplay3            ;display results

    call _runindicoff
    
    ld a,(err_occured)          ;display error option if applicable
    cp 0
    jp z,FinMenu_overerror

    ;turn error menu element on
    ld hl,FinMenu_menu_data + 8
    ld (hl),1
FinMenu_overerror:
    ld a,(statistics)           ;display if stat option is enabled
    cp 0
    jp z,FinMenu_overstat

    ;turn all stat menu elements on
    ld hl,FinMenu_menu_data + 16
    ld (hl),1
    ld hl,FinMenu_menu_data + 24
    ld (hl),1
    ld a,(calculation_mode)     ;if only two columns, then only two choices
    cp 0
    jp z,FinMenu_overstat
    ld hl,FinMenu_menu_data + 32
    ld (hl),1
FinMenu_overstat:
    ld hl,FinMenu_menu_data
    call menu
FinMenu_getkey:
    call _getkey                ;wait for a keypress
    cp kEnter                   ;is a=kEnter
    jp z,FinMenu_exit           ;prep jump to exit
    cp kExit
    jp z,FinMenu_exit           ;prep jump to exit
    cp kF1
    jp z,FinMenu_exit           ;prep jump to exit
    cp kLeft
    jp z,FinMenu_displaymore
    cp kRight
    jp z,FinMenu_displaymore
    cp kMore
    jp z,FinMenu_displaymore
    ld d,a
    ld a,(err_occured)
    cp 0
    jp z,FinMenu_getkey_overerror
    ld a,d
    cp kF2
    jp z,FinMenu_PrintErrors    ;print errors and return 
FinMenu_getkey_overerror:
    ld a,(statistics)
    cp 0
    jp z,FinMenu_getkey
    ld a,d
    cp kF3
    jp z,FinMenu_stat_choice1
    cp kF4
    jp z,FinMenu_stat_choice2
    ld d,a
    ld a,(calculation_mode)     ;if only two columns, then only two choices
    cp 0
    jp z,FinMenu_getkey
    ld a,d
    cp kF5
    jp z,FinMenu_stat_choice3 
    jp FinMenu_getkey
FinMenu_PrintErrors:
    call PrintErrors
    jp FinMenu
FinMenu_displaymore:
    ;switch top row display values
    ld ix,(FinDisplay_data_pointer)
    ld a,(ix + _FinDisplay_offset_top_row)
    cp _result_offset_sum_p
    jp z,FinMenu_displaymore_volume
    ld (ix + _FinDisplay_offset_top_row),_result_offset_sum_p
    jp FinMenu_displaymore_continue
FinMenu_displaymore_volume:
    ld (ix + _FinDisplay_offset_top_row),_result_offset_sum_v
FinMenu_displaymore_continue:

    call FinDisplay3            ;display results

    jp FinMenu_getkey
FinMenu_stat_choice1:
    ld a,1
    jp FinMenu_stat_choice
FinMenu_stat_choice2:
    ld a,2
    jp FinMenu_stat_choice
FinMenu_stat_choice3:
    ld a,3
    jp FinMenu_stat_choice
FinMenu_stat_choice:
    ;clear the menu
    call clearmenu

    ;export the results
    call ExportResults
    jp c,ErrDataUnused

    ;call the TIBASIC statistics processing program
    call _runindicon    ;turn on the run indicator
    ld hl,pname_BCStatisticsProcessor-1   ;copy anything before string name
                                               ; for type byte
        rst 20h                                ;call _Mov10toOP1
    call _exec_basic

    ;exit
    jp FinMenu_exit
FinMenu_exit:
    ;clear the menu
    call clearmenu
 
#ifdef DEBUG
    call TestPrints
    call VarDump
#endif
   
    ret
FinMenu_notimplemented:
    ld hl,notimplemented_message    ;display not implemented message
    call menuhighmessage   
    jp FinMenu_getkey
    
    ret                         ;return (just in case -- should never get here)


;============================================================
; BCStart -- displays the bucking calculator main screen and hands
;               execution to the user-specified routine
;  input: user keypress input
;  output: program branching
;  affects: assume everything
;  total: 204b
;  tested: no
;   NOTE: this routine is made to be jumped to
;============================================================
    jp BCStart ;just in case
BCStartWelcome_text: .db _welcome_text,0
BCStartClear_text: .db "    ",0
BCStart_menu_data:  
        .db 5,1,4,"EXIT"
        .db 28,1,5,"ABOUT"
        .db 53,1,5,"SETUP"
        .db 80,0,5,"STATS"
        .db 108,1,4,"BUCK"

BCStart:
    call _runindicoff
    
    call _clrScrn
    
        ld a,7                  ;display welcome text
    ld (_curCol),a
        ld a,2
    ld (_curRow),a
    ld hl,BCStartWelcome_text
    call _puts    
    
    ;check for statistics on/off
    ld a,(statistics)
    cp 0
    jp z,BCStart_menu
    ld hl,BCStart_menu_data + 24
    ld (hl),1
    
    ;display the menu
BCStart_menu:
    ld hl,BCStart_menu_data
    call menu
    ld hl,BCStart_menu_data + 24
    ld (hl),0
    
BCStart_getkey:
    call _getkey                ;wait for a keypress
    cp kEnter                   ;is a=kEnter
    jp z,BCStart_calculate    ;go to buck algorithm
    cp kF2
    jp z,BCStart_About        ;prep jump to BuckAbout
    cp kF1
    jp z,BCStart_exit         ;jump to program exit
    cp kExit
    jp z,BCStart_exit         ;jump to program exit
    cp kF5
    jp z,BCStart_calculate    ;go to buck algorithm
    cp kF3
    jp z,BCStart_setup
    ld d,a
    ld a,(statistics)
    cp 0
    jp z,BCStart_getkey
    ld a,d
    cp kF4
    jp z,BCStart_stat
    jp BCStart_getkey
BCStart_setup:
    ;handoff to the BCStup helper program
    call Handoff_BCStup
    jp BCStart
BCStart_stat:
    ;turn the run indicator on
    call _runindicon

    ;handoff to the bcstat statistics viewer program
    ld hl,pname_BCStatisticsViewer-1   ;copy anything before string name
                                               ; for type byte
        rst 20h                                ;call _Mov10toOP1
    call _exec_basic
    jp BCStart
BCStart_About:
    ld hl,BCStart
    push hl  ;so that we return to BCStart
    jp AboutBuck                ;jump to BCStart
BCStart_exit:
    call _clrScrn               ;clear the screen
    call _dispDone              ;print 'Done' to screen
    call _jforcecmdnochar       ;exit program
BCStart_calculate:
    ld a,(calculation_mode)
    cp 0
    jp z,BC_basic_calculate
    cp 1
    jp z,BC_usercompare_calculate
    cp 2
    jp z,BC_millcompare_calculate
    jp BCStart                ;just in case, do nothing
BCStart_notimplemented:
    ld hl,notimplemented_message    ;display not implemented message
    call menuhighmessage   
    jp BCStart_getkey
    
    ret                         ;return (just in case -- should never get here)


;============================================================
; BuckInput -- requests inputs for the bucking program and
;               generates the necessary running variables
;  input: user keypress input
;  output: variables -- log, log_dia, length, Li
;  affects: assume everything (I'm lazy right now)
;  total: 582b
;  tested: no
;   NOTE: this routine is made to be called
;============================================================
    jp BuckInput ;just in case!
BuckInputButt_text: .db "Butt Diam: ",0
BuckInputLength_text: .db "Lngth: ",0
BuckInputDiam_text: .db "Diam: ",0
BuckInputClear_text: .db "   ",0
BuckInputDiam_message: .db "Input   Diam   Please",0
BuckInput_numberdigits_temp: .db 0
BuckInput_menu_data:  
        .db 6,1,4,"EXIT"
        .db 28,0,1," "
        .db 51,0,1," "
        .db 77,0,1," "
        .db 110,1,3,"RUN"

BuckInput:
    call _clrScrn               ;clear screen

    ;clear the input variables
    call ClearInputs

    ;print the menu
    ld hl,BuckInput_menu_data
    call menu
    call clearmenumessage

BuckInput_after_clrScrn:
    ld a,0
    ld (temp),a
    
    ;clear inputs
    ld b,data_inputs_end - data_inputs_start
    ld hl,data_inputs_start
    call _ld_hl_bz              ;zero out all input memory before execution
    
BuckInput_start:    
        ld a,1                  ;display butt input text
    ld (_curCol),a
        ld a,0
    ld (_curRow),a
    ld hl,BuckInputButt_text
    call _puts
    
    ld a,1
    ld (temp),a
    jp BuckInput_getkey
BuckInputLength:                ;else
    ld hl,temp
    inc (hl)
    
    ld a,(hl)                   ;divide temp by 2 -- determines index to use
    sra a      
    
    ld (_curRow),a              ;display length input text
        ld a,0
    ld (_curCol),a
    ld hl,BuckInputLength_text
    call _puts
    
    jp BuckInput_getkey
BuckInputDiam:
    ld hl,temp
    inc (hl)
    
    ld a,(hl)                   ;divide temp by 2 -- determines index to use
    sra a      
    
    ld (_curRow),a              ;display diameter input text
        ld a,11
    ld (_curCol),a
    ld hl,BuckInputDiam_text
    call _puts
BuckInput_getkey:
    call _cursoron              ;turn blinking cursor on
    call _getkey                ;wait for a keypress
    cp kEnter                   ;is a=kEnter
    jp z,BuckInput_enter        ;it is...jump...
    cp kClear
    jp z,BuckInput_clear
    cp kF1
    jp z,BuckInput_exit
    cp kExit
    jp z,BuckInput_exit
    cp kF5
    jp z,BuckInput_run
    cp k0
    jp c,BuckInput_getkey
    cp k9+1
    jp c,BuckInput_number
    jp BuckInput_getkey
BuckInput_number:
    ld e,a                      ;a == keycode 
    ld a,(temp)
    sra a
    jp c,BuckInput_number+15    ;these jumps make a branch here unnecessary
    ld hl,log
    jp BuckInput_number+18
    ld hl,log_dia               ;<-- BuckInput_number+15
    ld a,(_curRow)              ;<-- BuckInput_number+18
    ld b,a
    call ArrayAccess
    ;check for zero, if zero with zero prev input then return to getkey
    ld a,0
    cp (hl)
    jp nz,BuckInput_number_nonzero
    ld a,e
    cp k0
    jp z,BuckInput_getkey
BuckInput_number_nonzero:
    ;prep and check number variable load
    ld a,e  ;e == keycode
    sub k0
    ld c,a  ;save for later (holds the number pressed)
    push hl ;save for later (holds address of variable)
    ld e,(hl)
    ld h,10                     ;bump up previous number one place-value
    call Mult8Bit               ;hl = h * e
    ld a,0                      ;is number within hardware limits?
    cp h
    jp z,BuckInput_number_nottoobig
BuckInput_number_toobig:        ;no, number is too big!
    pop hl  ;get this off the stack
    
    ld hl,toobig_message   ;display message
    call menumessage    
    
    jp BuckInput_clear          ;clear input and start over
BuckInput_number_nottoobig:     ;yes, number is okay
    ;load number to variable
    ld a,c                      ;retrieve our number
    add a,l                     ;add current number to previous number
    jp c,BuckInput_number_toobig ;guess not, number is still too big
    pop hl
    ld (hl),a                   ;load variable with new number
    
    ;print number to screen
    ld a,c                      ;retrieve our number    
    add a,L0                    ;convert number to its display value
    call _putc                  ;print number to screen
                                ;   it must not change!

    ;clear the message field
    call clearmenumessage
    
    ;return to getkey
    jp BuckInput_getkey
BuckInput_enter:
    call _cursoroff             ;turn blinking cursor off
    
    ;where was execution at when Enter key was pressed?
    ld a,(temp)
    sra a
    jp c,BuckInput_enterDiam    ;'Enter' at Diam
BuckInput_enterLength:          ;'Enter' at Length
    ;check for zero, if zero, don't advance, print message
    ld a,(_curRow)              ;is length zero?
    ld b,a
    ld hl,log
    call ArrayAccess
    ld a,0
    cp (hl)                     ;not zero, advance
    jp nz,BuckInput_enterLength_advance
    
    ld hl,temp                  ;yes zero, don't advance
    dec (hl)
    
    ld hl,inputsomething_message    ;display entry zero message
    call menumessage    
    
    jp BuckInputLength          ;return to Length execution
BuckInput_enterLength_advance:
    ;add previous length forward into current length (interpolator requirement)
    ld a,(hl)
    dec hl
    add a,(hl)                  ;add length forward
    inc hl
    push hl  ;necessary for consistancy
    jp c,BuckInput_number_toobig;check to see if we are too big now
    pop hl
    ld (hl),a                   ;load variable
    jp BuckInputDiam            ;advance
BuckInput_enterDiam:
    ;check for zero, if zero, don't advance, print message
    ld a,(_curRow)              ;is diam zero?
    ld b,a
    ld hl,log_dia
    call ArrayAccess
    ld a,0
    cp (hl)                     ;no, check for array end, advance
    jp nz,BuckInput_enterDiam_advance
    
    ld hl,temp                  ;yes, don't advance
    dec (hl)
    
    ld hl,inputsomething_message    ;display entry zero message
    call menumessage    
    
    ld a,(_curRow)
    dec a
    jp m,BuckInput_start        ;special case -- butt diameter
    jp BuckInputDiam            ;return to Diam execution
BuckInput_enterDiam_advance:    ;check for array end, advance
    ;check array bounds
    ld a,(_curRow)
    cp _log_entries              ;if we are within array bounds
    jp c,BuckInputLength        ;  advance to next length
    
    ;out of bounds, print message and getkey
    ld hl,noroom_message
    call menumessage        
    
    jp BuckInput_getkey
BuckInput_clear:
    call _cursoroff             ;turn blinking cursor off
    ;clear current entry and start over
    ld hl,_curCol               ;print over previous inputs
    dec (hl)
    dec (hl)
    dec (hl)
    ld hl,BuckInputClear_text
    call _puts

    ld hl,temp                  ;decrement index
    dec (hl)
    
    ld a,(hl)                   ;determine where execution was at
    sra a
    jp c,BuckInput_clearLength
    jp BuckInput_clearDiam      
BuckInput_clearLength:          ;clear stored length
    ld a,(_curRow)
    ld b,a
    ld hl,log
    call ArrayAccess
    ld (hl),0
    jp BuckInputLength          ;return to execution
BuckInput_clearDiam:            ;clear stored diam
    ld a,(_curRow)
    ld b,a
    dec a
    jp m,BuckInput_after_clrScrn ;special case -- butt diameter
    ld hl,log_dia               ;zero current log_dia array entry
    call ArrayAccess
    ld (hl),0
    jp BuckInputDiam            ;return to execution    
BuckInput_exit: 
    call _cursoroff             ;turn blinking cursor off
    call _clrScrn               ;clear the screen
    pop hl          ;this routine was called; must clean up stack before leaving
    jp BCStart
;    call _dispDone              ;print 'Done' to screen
;    call _jforcecmdnochar       ;exit program
BuckInput_run:
    ;check for completed log and continue on to algorithm
    ld a,(_curRow)              ;_curRow holds the index
    ld b,a                      ;if length is zero then log is okay
    ld hl,log
    call ArrayAccess
    ld a,0
    cp (hl)
    jp nz,BuckInput_runCheckDiam
    ld a,(_curRow)             ;correct index to load runtime variables properly
    dec a
    jp m,BuckInput_runTooEarly ;not elegant, but circumvents running prematurely
    ld (_curRow),a
    jp BuckInput_end           ;continue on to algorithm
BuckInput_runTooEarly:
    ;print diameter message and return to execution
    ld hl,pressenter_message
    call menumessage   
    jp BuckInput_getkey    
BuckInput_runCheckDiam:
    ld hl,log_dia               ;else if diam is zero then incomplete log
    call ArrayAccess
    ld a,0
    cp (hl)
    jp nz,BuckInput_end         ;continue on to algorithm
    
    ;print diameter message and return to execution
    ld hl,BuckInputDiam_message
    call menumessage   
     
    ld a,(temp)             ;if execution had been on diam, then return properly
    sra a
    jp nc,BuckInput_enter   ;return to execution as though 'Enter' was pressed
    ld a,(temp)
    dec a                   ;reset temp to allow execution to return properly
    ld (temp),a
    jp BuckInput_enter      ;return to execution as though 'Enter' was pressed
BuckInput_end:
    ;load final runtime variables
    ld a,(_curRow)
    ld b,a
    ld hl,log
    call ArrayAccess
    ld a,(hl)
    ld (length),a
    ld (Li),a

    ;copy raw data into user_guess_result_vars
    ld hl,data_inputs_start                         ;source
    ld de,user_guess_result_vars                    ;destination
    ld bc,user_sum_p - user_guess_result_vars       ;size
    ldir
    
    call _cursoroff             ;turn blinking cursor off
    call _clrScrn
    ret                         ;continue on to algorithm



;===============================================================================
; FinDisplay3 -- displays the program output in either two- or three-column 
;                   tabular form after a tree has been evaluated
;  input: FinDisplay_data_pointer  
;  output: table printed to the screen
;  affects: assume everything 
;  total: 685b (including ret)
;  tested: yes
;   NOTE: FinDisplay_data_pointer is a pointer to the display data structure
;         (ie: if IX holds the address of the data structure):
;           (IX+0) = pointer to the first column data 
;           (IX+2) = pointer to the second column data
;           (IX+4) = pointer to the third column data
;               NOTE: if (IX+4) is zero, then two column layout is used
;           (IX+6) = offset to the table headings
;           (IX+7) = offset to the first row data
;           (IX+8) = offset to the table body data
;           (IX+9) = offset to the x-check array, where this array is zero an
;                       'x' will be printed
;   NOTE: may be best to rewrite this routine to draw per column rather than 
;           per row
;===============================================================================
FinDisplay3:
    call clearwindow         ;erase everything but the menu

    ;load IX with the FinDisplay data pointer
    ld ix,(FinDisplay_data_pointer)

    ;load FinDisplay_unit_designator for top row unit symbol
    ld a,(ix + _FinDisplay_offset_top_row)
    cp _result_offset_sum_p
    jp nz,FinDisplay3_check_unit_designator2
    ld a,Ldollar
    ld (FinDisplay_unit_designator),a
    jp FinDisplay3_check_unit_designator_done
FinDisplay3_check_unit_designator2:
;   cp _result_offset_sum_v
;   jp nz,FinDisplay3_check_unit_designator3
    ld a,Lv
    ld (FinDisplay_unit_designator),a
;   jp FinDisplay3_check_unit_designator_done
;FinDisplay3_check_unit_designator3:
FinDisplay3_check_unit_designator_done:
    
    call headerbar          ;place black background along the top

    set textinverse,(iy+textflags)  ;white on black

    ;table heading one
    ld l,(ix + _FinDisplay_offset_col1_data)
    ld h,(ix + _FinDisplay_offset_col1_data + 1)
    ld c,(ix + _FinDisplay_offset_col_head)
    ld b,0
    add hl,bc
        ld a,5
    ld (_penCol),a
        ld a,0
    ld (_penRow),a
    call _vputs

    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
    ld a,71 ;<- does not affect flags
    jp z,FinDisplay3_overtablehead3 ;two
    ld l,(ix + _FinDisplay_offset_col3_data) ;three
    ld h,(ix + _FinDisplay_offset_col3_data + 1)
    ld c,(ix + _FinDisplay_offset_col_head)
    ld b,0
    add hl,bc
        ld a,95                     
    ld (_penCol),a              ;table heading three
        ld a,0
    ld (_penRow),a
    call _vputs
    
        ld a,53                
FinDisplay3_overtablehead3:
    ld l,(ix + _FinDisplay_offset_col2_data)    ;table heading two
    ld h,(ix + _FinDisplay_offset_col2_data + 1)
    ld c,(ix + _FinDisplay_offset_col_head)
    ld b,0
    add hl,bc
    ld (_penCol),a          
        ld a,0
    ld (_penRow),a
    call _vputs

    res textinverse,(iy+textflags)  ;default black on white
    
        ld a,0                  ;signify butt end with 'B'
    ld (_curCol),a
        ld a,2
    ld (_curRow),a
    ld a,LcapB
    call _putc
    
        ld a,0                  ;signify top end with 'T'
    ld (_curCol),a
        ld a,6
    ld (_curRow),a
    ld a,LcapT
    call _putc
    
    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
    ld a,10 ;<- does not affect flags
    jp z,FinDisplay3_overcolsep1 ;two columns
        ld a,7                  ;column separator
    ld (_curCol),a
        ld a,0
    ld (_curRow),a
    ld a,Lbar
    call _putc
        ld a,7
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld a,Lbar
    call _putc

        ld a,14
FinDisplay3_overcolsep1:
    ld (_curCol),a              ;column separator
        ld a,0
    ld (_curRow),a
    ld a,Lbar
    call _putc
        ld a,(_curCol)
    dec a
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld a,Lbar
    call _putc
    
        ld a,1                  ;money sign 1
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld a,(FinDisplay_unit_designator)
    call _putc

    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
    ld a,12 ;<- does not affect flags
    jp z,FinDisplay3_overmoneysign2 ;two columns
        ld a,8                  ;money sign 2
    ld (_curCol),a
    ld a,(FinDisplay_unit_designator)
    call _putc
    
        ld a,15            
FinDisplay3_overmoneysign2:
    ld (_curCol),a              ;money sign 3
    ld a,(FinDisplay_unit_designator)
    call _putc

    ;NOTE: any _dispOP1 outputs consume an entire line!  :-(

    ;display row one, column one table element
    ld l,(ix + _FinDisplay_offset_col1_data)
    ld h,(ix + _FinDisplay_offset_col1_data + 1)
    ld c,(ix + _FinDisplay_offset_top_row)
    ld b,0
    add hl,bc
        ld a,2  
    ld (_curCol),a
    ld a,0
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld h,d
    ld l,e
    call _dispAHL
    
    ;check for dollar display to cut tenths off
    ld a,(FinDisplay_unit_designator)
    cp Ldollar                  
    jp nz,FinDisplay3_overnotenths1
    ld hl,_curCol               ;cut tenths-place off of number
    dec (hl)                    ;  program internally stores prices *10
    ld a,Lspace
    call _putc
FinDisplay3_overnotenths1:
    
    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
        ld a,13 ;<- does not affect flags
    jp z,FinDisplay3_overprice3 ;two
        ld a,16                 ;three
    ld (_curCol),a              ;display price, column three
    ld l,(ix + _FinDisplay_offset_col3_data)
    ld h,(ix + _FinDisplay_offset_col3_data + 1)
    ld c,(ix + _FinDisplay_offset_top_row)
    ld b,0
    add hl,bc
    ld a,0
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld h,d
    ld l,e
    call _dispAHL
    
        ld a,1                  ;_curRow has incremented
    ld (_curRow),a              ;   reset _curRow

    ;check for dollar display to cut tenths off
    ld a,(FinDisplay_unit_designator)
    cp Ldollar                  
    jp nz,FinDisplay3_overnotenths3
    ld a,20                     ;cut tenths-place off of number
    ld (_curCol),a              ;  program internally stores prices *10
    ld a,Lspace
    call _putc
FinDisplay3_overnotenths3:
    
        ld a,1                  ;_curRow has incremented
    ld (_curRow),a              ;   reset _curRow

        ld a,9
FinDisplay3_overprice3:
    ld (_curCol),a              ;display price, column two
    ld l,(ix + _FinDisplay_offset_col2_data)
    ld h,(ix + _FinDisplay_offset_col2_data + 1)
    ld c,(ix + _FinDisplay_offset_top_row)
    ld b,0
    add hl,bc
    ld a,0
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld h,d
    ld l,e
    call _dispAHL
    
    ;check for dollar display to cut tenths off
    ld a,(FinDisplay_unit_designator)
    cp Ldollar                  
    jp nz,FinDisplay3_overnotenths2
    ld hl,_curCol               ;cut tenths-place off of number
    dec (hl)                    ;  program internally stores prices *10
    ld a,Lspace
    call _putc
FinDisplay3_overnotenths2:
     
        ld a,1
    ld (_curRow),a
    ld c,0
FinDisplay3_loop:                ;do while c < 5
    ld hl,_curRow    
    inc (hl)
    
    ;display column separators
    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
    ld a,10 ;<- does not affect flags
    jp z,FinDisplay3_loop_overcolsep1 ;two columns
        ld a,7                  ;column separator
    ld (_curCol),a
    ld a,Lbar
    call _putc
        ld a,14
FinDisplay3_loop_overcolsep1:
    ld (_curCol),a              ;column separator
    ld a,Lbar
    call _putc
    
    ;print first length, element
    push ix
        ld a,1                  ;print first length, element
    ld (_curCol),a
    ld d,c                      ;save C 
    ld l,(ix + _FinDisplay_offset_col1_data)
    ld h,(ix + _FinDisplay_offset_col1_data + 1)
    ld c,(ix + _FinDisplay_offset_table_body)
    ld b,0
    add hl,bc ;DAVID-- THIS IS WHERE THE DISPLAY SHIFT MUST OCCUR
    push hl
    pop ix
    ld c,d                      ;recall C
    call PrintArrayElm
    pop ix
    
    ;if log price == 0, print 'x' next to length
    ld d,c                      ;save C
    ld l,(ix + _FinDisplay_offset_col1_data)
    ld h,(ix + _FinDisplay_offset_col1_data + 1)
    ld c,(ix + _FinDisplay_offset_x_check_array)
    ld b,0
    add hl,bc
    ld b,d
    call ArryAccessW
    ld a,0
    cp (hl)
    jp nz,FinDisplay3_loop_overx1
    inc hl
    cp (hl)
    jp nz,FinDisplay3_loop_overx1
    ld a,Lx
    call _putc
FinDisplay3_loop_overx1:
    ld c,b
    ld b,0

    ;print next two length elements
    ld a,(ix + _FinDisplay_offset_col3_data) ;two columns or three?
    cp 0
    ld a,12 ;<- does not affect flags
    jp z,FinDisplay3_loop_overlength3 ;two columns
        ld a,15                 ;print third column length, element
    ld (_curCol),a
    push ix
    ld d,c                      ;save C
    ld l,(ix + _FinDisplay_offset_col3_data)
    ld h,(ix + _FinDisplay_offset_col3_data + 1)
    ld c,(ix + _FinDisplay_offset_table_body)
    ld b,0
    add hl,bc
    push hl
    pop ix
    ld c,d                      ;recall C
    call PrintArrayElm
    pop ix

    ;if log price == 0, print 'x' next to length
    ld d,c                      ;save C
    ld l,(ix + _FinDisplay_offset_col3_data)
    ld h,(ix + _FinDisplay_offset_col3_data + 1)
    ld c,(ix + _FinDisplay_offset_x_check_array)
    ld b,0
    add hl,bc
    ld b,d
    call ArryAccessW
    ld a,0
    cp (hl)
    jp nz,FinDisplay3_loop_overx3
    inc hl
    cp (hl)
    jp nz,FinDisplay3_loop_overx3
    ld a,Lx
    call _putc
    ld hl,_curRow               ;_curRow will have incremented
    dec (hl)                    ;   reset _curRow
FinDisplay3_loop_overx3:
    ld c,b
    ld b,0

        ld a,8
FinDisplay3_loop_overlength3:
    ld (_curCol),a
    push ix
    ld d,c                      ;save C
    ld l,(ix + _FinDisplay_offset_col2_data)
    ld h,(ix + _FinDisplay_offset_col2_data + 1)
    ld c,(ix + _FinDisplay_offset_table_body)
    ld b,0
    add hl,bc
    push hl
    pop ix
    ld c,d                      ;recall C
    call PrintArrayElm
    pop ix

    ;if log price == 0, print 'x' next to length
    ld d,c                      ;save C
    ld l,(ix + _FinDisplay_offset_col2_data)
    ld h,(ix + _FinDisplay_offset_col2_data + 1)
    ld c,(ix + _FinDisplay_offset_x_check_array)
    ld b,0
    add hl,bc
    ld b,d
    call ArryAccessW
    ld a,0
    cp (hl)
    jp nz,FinDisplay3_loop_overx2
    inc hl
    cp (hl)
    jp nz,FinDisplay3_loop_overx2
    ld a,Lx
    call _putc
FinDisplay3_loop_overx2:
    ld c,b
    ld b,0

    inc c                       ;if c < 5 continue looping
    ld a,4
    cp c
    jp nc,FinDisplay3_loop
    
    ;return
    ret



;==============================================================================
; headerbar -- draws a black header bar at the top of the screen
;  input: none
;  output: black bar drawn at top of screen
;  affects: Assume everything
;  total: 37b (excluding called functions, including ret)
;  tested: yes
;==============================================================================
    jp headerbar         ;just in case!
headerbar_row:
    .db %11111111,%11111111,%11111111,%11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111,%11111111,%11111111,%11111111,%11111111,%11111111
    .db %11111111,%11111111

headerbar:                  ;writes over everything there
                        ;no need to _clrLCD
    ld de,$fc00         ;where to start
    ld b,7
headerbar_loop:
        push bc
    ld hl,headerbar_row ;predone row of bytes
    ld bc,$10           ;one row
    ldir
        pop bc
    djnz headerbar_loop
    ret




