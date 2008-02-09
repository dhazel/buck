

;* BCLP2 -- The Length and Price editor, version 2
;*  NOTE: This is a separate program. The main block is titled LengthPrice.
;*          BCLP2 used to be an includable routine, but its size became
;*              prohibitive of that.
;*******************************************************************************

#include bc_includes.asm

.org _asm_exec_ram ;PROGRAM START
;
; LengthPrice -- main execution block
;  tested: yes
;   NOTE: these comments are here for compliance with the dependency parser
;
    jp LengthPrice

#include bc_data.asm
#include BCLP2.asm.inc          ;autogenerated include file

        
LengthPrice:
#ifndef DEBUG
    ;check for tampering/piracy
    call TamperChk
#endif

    ;set screen and selection location for the editor
    ld a,(LCV_size)
    ld hl,BCLP2_screen_location
    ld (hl),a
    ld hl,BCLP2_selection_location
    ld (hl),a

    ;call the editor
    call BCLP2

    ;write data back over to BCStup, this module is no longer called by BC
    ld hl,pname_BCSetup             ;NOTE: only if data blocks are compatable
                                    ;   can you make this work with multiple 
    call copyover_data              ;   versions of bc!

    ;return
    ret


;============================================================
; BCLP2 -- displays, updates, and populates the mill log 
;               length and prices variables 
;               ('LCV' and 'prices')
;  input: user keypress input
;  output: variables -- LCV, prices
;  affects: assume everything 
;  total: 2330b
;  tested: yes
;============================================================
    jp BCLP2 ;just in case!
BCLP2_headwrapper_text: .db "---[             ]---",0
BCLP2_header_text: .db "       Length/Price   Editor",0
BCLP2_menu1_data:
    .db 6,1,3,"DEL"
    .db 0,0,1," "
    .db 0,0,1," "
    .db 0,0,1," "
    .db 108,1,4,"DONE"
BCLP2_menu2_data:
    .db 3,1,5,"INSRT"
    .db 0,0,1," "
    .db 0,0,1," "
    .db 0,0,1," "
    .db 108,1,4,"DONE"
BCLP2_menu3_data:
    .db 5,1,4,"CRIT"
    .db 0,0,1," "
    .db 0,0,1," "
    .db 0,0,1," "
    .db 108,1,4,"DONE"
BCLP2_menu4_data:
    .db 4,1,4,"WIPE"
    .db 0,0,1," "
    .db 0,0,1," "
    .db 0,0,1," "
    .db 108,1,4,"DONE"
BCLP2_top_message: .db "                           TOP!",0
BCLP2_bottom_message: .db "                      BOTTOM!",0
BCLP2_editing_message: .db "                    EDITING",0
BCLP2_repeatentry_message: .db "No   Duplicate   Lengths",0
BCLP2_pleaseinputatleastonevalue_bigmessage_text: .db "Please input at         least one value",0
BCLP2_pleaseinputatleastonevalue_bigmessage: .dw BCLP2_pleaseinputatleastonevalue_bigmessage_text,okay_text,okay_text
BCLP2_wipe_bigmessage_text: .db "This will clear all lengths and prices",0
BCLP2_wipe_bigmessage: .dw BCLP2_wipe_bigmessage_text,cancel_text,okay_text
BCLP2_delete_bigmessage_text: .db "Delete this            length/price pair?",0
BCLP2_delete_bigmessage: .dw BCLP2_delete_bigmessage_text,cancel_text,okay_text
BCLP2_deletelastelement_bigmessage: .dw BCLP2_delete_bigmessage_text,cancel_text,okay_text
BCLP2_resetstats_bigmessage_text: .db "Reset stats?        This will erase all  statistics data for  the current mill.",0
BCLP2_resetstats_bigmessage: .dw BCLP2_resetstats_bigmessage_text,cancel_text,okay_text
BCLP2_statskew_bigmessage_text: .db "Lengths changed.    Stats should be resetto prevent future    lost data.",0
BCLP2_statskew_bigmessage: .dw BCLP2_statskew_bigmessage_text,okay_text,okay_text
BCLP2_screen_location: .db 0      ;track screen location
BCLP2_selection_location: .db 0,1 ;track selection location
BCLP2_menu_location: .db 0        ;track the switchable menu
BCLP2_editing: .db 0              ;track whether or not we are editing


BCLP2_drawscreen: ;draws the screen
    ; input: BCLP2_screen_location 
    ;           (offset of the first LCV element previously on screen)
    ;        BCLP2_selection_location 
    ;           (tuple; entry1==element number, entry2==column number {1,2})
    ;        BCLP2_menu_location (switchable menu view) {0-2}
    ;        name_mill  (name of mill; zero-terminated string)
    ;        LCV        (255-terminated array of accepted lengths)
    ;        prices     (array of corresponding prices)
    ;        IX = pointer to message text
    ;
    ld a,0                      ;reset editing status (turn it off)
    ld (BCLP2_editing),a

    push ix                     ;pointer to message text

    ;draw the menu
BCLP2_drawscreen_menu:
    ld a,(BCLP2_menu_location)
    cp 0
    jp nz,BCLP2_drawscreen_menu2

    ld hl,BCLP2_menu1_data
    call menu

    jp BCLP2_drawscreen_menumessage
BCLP2_drawscreen_menu2:
    cp 1
    jp nz,BCLP2_drawscreen_menu3
    
    ld hl,BCLP2_menu2_data
    call menu

    jp BCLP2_drawscreen_menumessage
BCLP2_drawscreen_menu3:
    cp 2
    jp nz,BCLP2_drawscreen_menu4

    ld hl,BCLP2_menu3_data
    call menu

    jp BCLP2_drawscreen_menumessage
BCLP2_drawscreen_menu4:
    ld a,3                      ;failsafe in case menu is wrong
    ld (BCLP2_menu_location),a

    ld hl,BCLP2_menu4_data
    call menu

    jp BCLP2_drawscreen_menumessage
BCLP2_drawscreen_menumessage:
    ;display message text
    pop hl
    call menumessage

    call clearwindow            ;clear everthing but the menu

    call _homeup

    ld hl,BCLP2_headwrapper_text
    call _puts
    
        ld a,24                 ;display header text
    ld (_penCol),a
        ld a,0
    ld (_penRow),a
    ld hl,BCLP2_header_text
    call _vputs

    ;display mill name on right-hand side
        ld a,6                  ;start in the sixth row down 
    ld (_penRow),a
    ld hl,mill_name           ;load the name into HL
    push hl
    ld bc,currentmill_number - mill_name  ;extra safeguard (used by cpi below)
BCLP2_drawscreen_nameloop:
    ld a,121                    ;write the letters in the 121st column
    ld (_penCol),a
    pop hl
    ld a,(hl)                   ;load the letter for display
    inc hl                      ;increment to the next letter
    push hl
    push bc
    call _vputmap               ;display the letter in v-width font
    pop bc
    ld a,(_penRow)
    add a,6                     ;move down six rows for the next letter
    ld (_penRow),a
    ld a,0                      
    cpi                         ;check for zero element or BC index end
    jp nz,BCLP2_drawscreen_nameloop
    pop hl

    ;calculate new screen location
    ld a,(BCLP2_screen_location)
    ld hl,BCLP2_selection_location
    sub (hl)
    jp m,BCLP2_drawscreen_screenup    ;scroll up
    cp 6
    jp c,BCLP2_drawscreen_display     ;don't scroll
    ld a,(BCLP2_selection_location)   ;scroll down
    add a,5                             ;add 5 to selection location
    ld hl,BCLP2_screen_location
    ld (hl),a                           ;load result as new screen location
    jp BCLP2_drawscreen_display
BCLP2_drawscreen_screenup:            ;scroll up
    ld hl,BCLP2_screen_location       ;load selection loc as new screen loc
    ld a,(BCLP2_selection_location)
    ld (hl),a

    ;display LCV and prices data
BCLP2_drawscreen_display:
    ld a,(BCLP2_screen_location)
    ld hl,LCV_size
    cp (hl)                     ;check screen location
    jp nc,BCLP2_drawscreen_overuparrow
        ld a,0                  ;set arrow location (column)
    ld (_curCol),a
        ld a,1                  ;set uparrow location (row)
    ld (_curRow),a
    ld a,LupArrow
    call _putc
BCLP2_drawscreen_overuparrow:
    ld a,(BCLP2_screen_location)
    cp 6
    jp c,BCLP2_drawscreen_overdownarrow
        ld a,0                  ;set arrow location (column)
    ld (_curCol),a
        ld a,6                  ;set downarrow location (row)
    ld (_curRow),a
    ld a,LdownArrow
    call _putc
BCLP2_drawscreen_overdownarrow:
        ld a,0                  ;set cursor location
    ld (_curRow),a
    ld d,0
    push de
BCLP2_drawscreen_display_loop:;do while d < 5
    ld hl,_curRow    
    inc (hl)                    ;move to next row

    ld a,(hl)                   ;set array index
    dec a
    ld b,a
    ld a,(BCLP2_screen_location)
    sub b
    ld c,a                      ;c <- array index
    
    ;check for selection location
    ld a,(BCLP2_selection_location)
    cp c
    jp nz,BCLP2_drawscreen_overtexthighlight1
    ld a,(BCLP2_selection_location + 1)
    cp 1
    jp nz,BCLP2_drawscreen_overtexthighlight1
    set textinverse,(iy+textflags)  ;highlight text
BCLP2_drawscreen_overtexthighlight1:   
        ld a,2                  ;set cursor column
    ld (_curCol),a
    ld ix,LCV                   ;print LCV element
    ld a,1                      ;element print mode
    call PrintArrayElm_drawscreen
    res textinverse,(iy+textflags)  ;reset highlighting

    ld a,Lapostrophe            ;foot symbol
    call _putc

    ;check for criteria, mark if so
    ld hl,vol_constrain
    ld b,c                      ;B <- array index
    call ArrayAccess_ne
    ld a,(hl)
    cp 1
    jp z,BCLP2_drawscreen_criteria
    ld hl,minmax_td
    call ArryAccessW_ne
    ld b,0
    ld a,0
    cp (hl)
    jp z,BCLP2_drawscreen_overcriteria1
    ld b,1
BCLP2_drawscreen_overcriteria1:
    inc hl
    cp (hl)
    jp z,BCLP2_drawscreen_overcriteria2
    ld b,1
BCLP2_drawscreen_overcriteria2:
    cp b
    jp z,BCLP2_drawscreen_overcriteria
BCLP2_drawscreen_criteria:
        ld a,8                  ;the letter "c" (short for criteria)
    ld (_curCol),a
    ld a,Lc
    call _putc
BCLP2_drawscreen_overcriteria:
        ld a,10                 ;dollar symbol
    ld (_curCol),a
    ld a,Ldollar
    call _putc
     
    ;check for selection location
    ld a,(BCLP2_selection_location)
    cp c
    jp nz,BCLP2_drawscreen_overtexthighlight2
    ld a,(BCLP2_selection_location + 1)
    cp 2
    jp nz,BCLP2_drawscreen_overtexthighlight2
    set textinverse,(iy+textflags)  ;highlight text
BCLP2_drawscreen_overtexthighlight2:
        ld a,11                 ;print prices element
    ld (_curCol),a
    ld a,(LCV_size)
    cp c                        ;if (index > LCV_size) print empty space
    jp c,BCLP2_drawscreen_price_empty
    ld a,c
    ld ix,prices
    call PrintArrayLWElm
    jp BCLP2_drawscreen_over_price_empty
BCLP2_drawscreen_price_empty:
    ld hl,clearselection_text
    call _puts
BCLP2_drawscreen_over_price_empty:
    res textinverse,(iy+textflags)  ;reset highlighting
    
    pop de
    inc d                       ;if d < 5 continue looping
    push de
    ld a,5
    cp d
    jp nc,BCLP2_drawscreen_display_loop
    pop de

    ret
    

BCLP2_delete: ;deletes the selected length/price pair
    ; inputs: BCLP2_selection_location
    ;         LCV_size
    ;
    ;check for ends of array, and for LCV_size == 0
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    cp (hl)
    jp z,BCLP2_delete_arrayend
    jp nc,BCLP2_delete_arraymiddle
    ret ;out of array bounds, return
BCLP2_delete_lastelement: ;don't let LCV_size or index step over zero
    ld hl,LCV_size
    inc (hl)
    ld a,1
BCLP2_delete_arrayend:
    dec a
    jp m,BCLP2_delete_lastelement ;stepped over zero
    call BCLP2_clearpair   ;clear the deleted elements
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    dec a                       ;decrement LCV_size
    ld (LCV_size),a
    ld (hl),a
    ld hl,BCLP2_screen_location
    ld (hl),a
    ret             ;return
BCLP2_delete_arraymiddle:
    ;set the number of loop iterations
    ld a,(BCLP2_selection_location)
    ld b,a
    ld a,(LCV_size)
    sub b
    ld b,a
    push bc                     ;B == # elements between selection and array end

    ;load the addresses for starting the LCV transfer
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,LCV                   
    call ArrayAccess_ne
    
    pop bc                      ;B == # elements between selection and array end
    push bc
    call ByteLShift             ;transfer (shorten the array)

    ;load the addresses for starting the volume constraint transfer
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,vol_constrain
    call ArrayAccess_ne
    
    pop bc                      ;B == # elements between selection and array end
    push bc
    call ByteLShift             ;transfer (shorten the array)

    ;load the addresses for starting the top diameter criteria transfer
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,minmax_td                   
    call ArryAccessW_ne

    pop bc                      ;B == # elements between selection and array end
    push hl                     ;for criteria, ByteLShift must be run twice
                                ;  because minmax_td is a data-word array
    sla b                       ;multiply the loop iterator by two
    inc b
    push bc
    
    call ByteLShift

    pop bc
    pop hl
    push bc
    call ByteLShift

    ;load the addresses for starting the prices transfer
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,prices                   
    call ArryAccessW_ne

    pop bc                      ;for prices, ByteLShift must be run twice
    push hl                     ;  because prices is a data-word array
    push bc                     ;BC has already been multiplied by 2
    
    call ByteLShift

    ;set screen return characteristics and new LCV size
    ld hl,LCV_size
    dec (hl)                    ;decrement LCV_size
    ld hl,BCLP2_screen_location
    dec (hl)                    ;decrement screen location
    ld hl,BCLP2_selection_location
    dec (hl)                    ;decrement selection location

    pop bc
    pop hl
    call ByteLShift

    ret             ;return

BCLP2_insert: ;inserts a new length/price pair
    ; inputs BCLP2_selection_location
    ;        LCV_size
    ;
    ;check whether there is room left
    ld a,(LCV_size)
    cp 19                       ;the array can only hold 20 elements
    jp nc,BCLP2_insert_noroomreturn

    ;check for ends of array, and for LCV_size == 0
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    cp (hl)
    jp z,BCLP2_insert_arrayend        ;on the end of the array
    jp nc,BCLP2_insert_arraymiddle    ;middle of the arrays
    jp BCLP2_insert_offtheends        ;off the end of the array
BCLP2_insert_arrayend:
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    inc a                       ;increment LCV_size
    ld (LCV_size),a
    ld (hl),a
    ld hl,BCLP2_screen_location
    ld (hl),a
    call BCLP2_clearpair      ;make sure that the inserted pair is zeroed out
    ret                         ;return
BCLP2_insert_offtheends:
    ;check for top end of array
    dec (hl)
    cp (hl)
    jp z,BCLP2_insert         ;top end, decrement selection and restart insert
    inc (hl)                    ;bottom end, re-increment selection
BCLP2_insert_arraymiddle:
    call BCLP2_insert_arraymiddle_routine
    ld hl,BCLP2_selection_location
    inc (hl)                    ;increment selection location
    ld hl,BCLP2_screen_location
    inc (hl)
    call BCLP2_clearpair
    ret                         ;return
BCLP2_insert_arraymiddle_routine:
    ;set the number of loop iterations
    ld a,(BCLP2_selection_location)
    inc a                       ;stop before getting to selection
    ld b,a
    ld a,(LCV_size)
    sub b
    jp nc,BCLP2_insert_arraymiddle_routine_normal
    ld hl,BCLP2_selection_location
    inc (hl)
    ld a,(LCV_size)             ;special case, want to insert new zero index
    inc a                       ;we want to move everything up
BCLP2_insert_arraymiddle_routine_normal:
    ld b,a
    push bc                     ;save for recall 

    ;load the addresses for starting the LCV transfer
    ld a,(LCV_size)
    ld b,a
    ld hl,LCV                   
    call ArrayAccess_ne
    ld d,h
    ld e,l
    inc de

    pop bc
    push bc
    call BCLP2_insert_loop    ;transfer (lengthen the array)

    ;load the addresses for starting the volume constraint transfer
    ld a,(LCV_size)
    ld b,a
    ld hl,vol_constrain                   
    call ArrayAccess_ne
    ld d,h
    ld e,l
    inc de

    pop bc
    push bc
    call BCLP2_insert_loop    ;transfer (lengthen the array)

    ;load the addresses for starting the top diameter criteria transfer
    ld a,(LCV_size)
    ld b,a
    ld hl,minmax_td
    call ArryAccessW_ne
    inc hl
    ld d,h
    ld e,l
    inc de

    pop bc                      ;for criteria, insert_loop must be entered twice
    push hl                     ;  because minmax_td is a data-word array
    push de
    sla b                       ;multiply the loop iterator by two
    inc b
    push bc
    
    call BCLP2_insert_loop
 
    pop bc
    pop de
    pop hl
    push bc
    inc de
    inc hl
    call BCLP2_insert_loop

    ;load the addresses for starting the prices transfer
    ld a,(LCV_size)
    ld b,a
    ld hl,prices                   
    call ArryAccessW_ne
    inc hl
    ld d,h
    ld e,l
    inc de

    pop bc                      ;for prices, delete_loop must be entered twice
    push hl                     ;  because prices is a data-word array
    push de
    push bc                     ;the loop iterator is already multiplied by 2
    
    call BCLP2_insert_loop
 
    ld hl,LCV_size
    inc (hl)                    ;increment LCV_size

    pop bc
    pop de
    pop hl
    inc de
    inc hl
BCLP2_insert_loop: ;iteratively copies (HL) into (DE)
    ld a,(hl)
    ld (de),a

    dec hl
    dec de

    dec b
    jp p,BCLP2_insert_loop

    ret             ;return
BCLP2_insert_noroomreturn:    ;no more room in the arrays
    pop hl                      ;remove the call return address
    ld a,0                      ;check stack for numberedit
    pop bc                      ;   (will be an address if not numberedit)
    cp b                        ;   (B should be nonzero if not numberedit)
    jp z,BCLP2_insert_noroomreturnonnumberedit
    push bc                     ;push BC back onto the stack
BCLP2_insert_noroomreturnonnumberedit:
    ld ix,noroom_message
    call BCLP2_drawscreen
    jp BCLP2_getkey
    ret             ;return (just in case)

BCLP2_clearpair: ;clears the length/price pair (including criteria)
    ; inputs: BCLP2_selection_location
    ;
    call BCLP2_clearelement   ;clear the first element
    ld a,(BCLP2_selection_location + 1)
    xor 3               ;these two instructions will switch A between 1 and 2
    and 3
    ld (BCLP2_selection_location + 1),a
    call BCLP2_clearelement
    ld a,(BCLP2_selection_location + 1)
    xor 3               ;these two instructions will switch A between 1 and 2
    and 3
    ld (BCLP2_selection_location + 1),a
    call BCLP2_clearcriteria
    ret

BCLP2:
    call _runindicoff           ;turn run indicator off

    call clearmenumessage
    ld ix,empty_text
    call BCLP2_drawscreen     ;draw the screen
    ;
BCLP2_getkey:
    call _getkey                ;wait for a keypress
    cp kEnter                   ;is a=kEnter
    jp z,BCLP2_edit           ;it is...jump...
    cp kClear
    jp z,BCLP2_edit
    cp kExit
    jp z,BCLP2_done
    cp kUp
    jp z,BCLP2_up
    cp kDown
    jp z,BCLP2_down
    cp kLeft
    jp z,BCLP2_columnswitch
    cp kRight
    jp z,BCLP2_columnswitch
    cp kF5
    jp z,BCLP2_done
    cp kF1
    jp z,BCLP2_switchablemenu
    cp kDel
    jp z,BCLP2_call_delete
    cp kMore
    jp z,BCLP2_menuswitch
    cp k0
    jp c,BCLP2_getkey
    cp k9+1
    jp c,BCLP2_numberedit
    jp BCLP2_getkey
BCLP2_switchablemenu:
    ld a,(BCLP2_menu_location)
    cp 0
    jp z,BCLP2_call_delete
    cp 1
    jp z,BCLP2_call_insert
    cp 2
    jp z,BCLP2_call_criteria
    cp 3
    jp z,BCLP2_wipe
    jp BCLP2_getkey
BCLP2_menuswitch:
    ld a,(BCLP2_menu_location)
    cp 3
    jp z,BCLP2_menuswitch_rotate
    inc a
    ld (BCLP2_menu_location),a
    jp BCLP2
BCLP2_menuswitch_rotate:
    ld a,0
    ld (BCLP2_menu_location),a
    jp BCLP2
BCLP2_call_delete:
    ld ix,BCLP2_delete_bigmessage
    call bigmessage
    call _getkey
    cp kF4
    jp nz,BCLP2            ;return to main window

    call BCLP2_delete     ;delete current length/price pair
    
    jp BCLP2              ;return to main window
BCLP2_call_insert:
    call BCLP2_insert     ;insert new length/price pair

    jp BCLP2              ;return to main window
BCLP2_call_criteria:
    ;load the selection index and call the criteria editor
#if _allow_BCLP2_criteria_traversal == 0
    ld a,0                  ;make LCV non-traversable
    ld (CriteriaEditor_LCV_traversal),a
#else
    ld a,1                  ;make LCV traversable
    ld (CriteriaEditor_LCV_traversal),a
#endif
        ld a,1
    ld (_winTop),a          ;make the editor look "embedded"
    ld a,(BCLP2_selection_location)
    cp 255
    jp z,BCLP2_getkey
    call CriteriaEditor     ;call the criteria editor
        ld a,0              ;reset the _winTop
    ld (_winTop),a
    
    jp BCLP2              ;return to main window
BCLP2_up:
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    cp (hl)
    jp z,BCLP2_up_top     ;we do not want to step past array end
    jp BCLP2_up_okay
BCLP2_up_top:
    ld hl,BCLP2_top_message
    call menumessage
    jp BCLP2_getkey
BCLP2_up_okay:
    inc (hl)
    jp BCLP2
BCLP2_down:
    ld hl,BCLP2_selection_location
    ld a,255    ;we must be able to step one past array start in main screen
    cp (hl)
    jp z,BCLP2_down_bottom
    dec (hl)
    jp BCLP2
BCLP2_down_bottom:
    ld hl,BCLP2_bottom_message
    call menumessage
    jp BCLP2_getkey
BCLP2_columnswitch:
    ld a,(BCLP2_selection_location + 1)
    xor 3               ;these two instructions will switch A between 1 and 2
    and 3
    ld (BCLP2_selection_location + 1),a
    jp BCLP2
BCLP2_wipe:
    ld ix,BCLP2_wipe_bigmessage
    call bigmessage
    call _getkey
    cp kF4
    jp nz,BCLP2            ;restart editor

    ;clear length and price data
    ld b,data_LP_end - data_LP_start
    ld hl,data_LP_start
    call _ld_hl_bz          ;zero out all length and price data before execution

    ;reset LCV_size, screen location, and selection location
    ld a,0
    ld (LCV_size),a
    ld (BCLP2_screen_location),a
    ld (BCLP2_selection_location),a
    ld a,1
    ld (BCLP2_selection_location + 1),a

    ld ix,inputsomething_message
    call BCLP2_drawscreen

    jp BCLP2_getkey              ;enter edit mode
BCLP2_clearselection:             ;clear screen element but not data
    ld a,(BCLP2_screen_location)  ;calculate display row
    ld hl,BCLP2_selection_location
    sub (hl)
    inc a
    ld (_curRow),a
    inc hl                          ;determine display column
    ld a,(hl)
    cp 1
    jp nz,BCLP2_clearselection_row2
    ld a,2
    ld (_curCol),a
    ld hl,clearselection_text
    call _puts
    ld a,3
    ld (_curCol),a
    ret
BCLP2_clearselection_row2:
    ld a,11
    ld (_curCol),a
    ld hl,clearselection_text
    call _puts
    ld a,12
    ld (_curCol),a
    ret
BCLP2_numberedit_prenumber:
    ld a,c
    jp BCLP2_number
BCLP2_numberedit:             ;number pressed while in the main window
    ld b,0
    ld c,a
    push bc
BCLP2_edit:                   
    ;clear out the selection 
        ld a,7
    ld (_curRow),a
        ld a,0
    ld (_curCol),a
    ld hl,clearselection_text
    call _puts

    ;clear out the menu
    call clearmenu
    ld hl,BCLP2_editing_message
    call menumessage
    
    ;check where we are, do we need to insert?
    ld hl,BCLP2_selection_location
    ld a,(LCV_size)
    cp (hl)
    call c,BCLP2_insert

    call BCLP2_clearselection     ;clear the current selection

    ld a,0                      ;check stack for numberedit
    pop bc                      ;   (will be an address if not numberedit)
    cp b                        ;   (B should be nonzero if not numberedit)
    jp z,BCLP2_numberedit_prenumber
    push bc                     ;push BC back onto the stack
BCLP2_edit_getkey:
    call _cursoron              ;turn blinking cursor on
    call _getkey                ;wait for a keypress
    cp kEnter                   ;is a=kEnter
    jp z,BCLP2_enter           ;it is...jump...
    cp kExit
    jp z,BCLP2_enter
    cp kUp
    jp z,BCLP2_enter
    cp kDown
    jp z,BCLP2_enter
    cp kLeft
    jp z,BCLP2_enter
    cp kRight
    jp z,BCLP2_enter
    cp kClear
    jp z,BCLP2_clear
    cp kDel
    jp z,BCLP2_clear
    cp k0
    jp c,BCLP2_edit_getkey
    cp k9+1
    jp c,BCLP2_number
    jp BCLP2_edit_getkey
BCLP2_number:
    ld e,a                      ;e <- keycode 
    ld a,(BCLP2_editing)      ;if editing, don't clear the element
    cp 1
    jp z,BCLP2_number_noclear
    call BCLP2_clearelement   ;clear the element
    ld a,1                      ;set the editing flag
    ld (BCLP2_editing),a
BCLP2_number_noclear:
    ld a,(BCLP2_selection_location + 1)
    cp 2
    jp c,BCLP2_number_length
    jp BCLP2_number_price
BCLP2_number_length:
    ld hl,LCV
    ld a,(BCLP2_selection_location)  
    ld b,a
    call ArrayAccess_ne
    ;check for zero, if zero with zero prev value then return to getkey
    ld a,0
    cp (hl)
    jp nz,BCLP2_number_length_nonzero
    ld a,e
    cp k0
    jp z,BCLP2_edit_getkey
    jp BCLP2_number_length_nonzero
BCLP2_number_price:
    ld hl,prices                
    ld a,(BCLP2_selection_location)  
    ld b,a
    call ArryAccessW_ne
    ;check for zero, if zero with zero current value then return to getkey
    ld a,0
    inc hl                      ;price array is little-endian!!!
    cp (hl)
    dec hl ;<- does not affect flags
    jp nz,BCLP2_number_price_nonzero
    cp (hl)
    jp nz,BCLP2_number_price_nonzero
    ld a,e
    cp k0
    jp z,BCLP2_edit_getkey
    jp BCLP2_number_price_nonzero
BCLP2_number_length_nonzero:
    ;prep and check number variable load
    ld a,e  ;e == keycode
    sub k0
    ld c,a  ;save for later (holds the number pressed)
    push hl ;save for later (holds address of length variable)
    ld e,(hl)                   ;e <- current length
    ld h,10                     ;bump up current length one place-value
    call Mult8Bit               ;hl = h * e
    ld a,0                      ;is number within hardware limits?
    cp h
    jp z,BCLP2_number_length_nottoobig
    jp BCLP2_number_toobig
BCLP2_number_price_nonzero: 
    ;prep and check number variable load
    ld a,e  ;e == keycode
    sub k0
    ld c,a  ;save for later (holds number pressed)
    push hl ;save for later (holds address of variable)
    ld e,(hl) ;price array remains little-endian to make compile-in debugging straightforward
    inc hl
    ld d,(hl)
    ld a,10                     ;bump up previous number one place-value
    call Mult8to16Bit            ;hl = de * a
    ld a,$07                    ;is number within algorithm limits?
    cp h
    jp c,BCLP2_number_toobig
    ;
   ;NOTE -- (price * (volume / 100)) must not exceed 65535 (or hex FFFF)
    ;  A 40' log with 32" diam has a scribner volume of 1840; these are the 
    ;      current algorithm limits. A safe maximum price at these limits
    ;      is 3327 (or hex CFF).
    ;  I have set the maximum price at 2047 (or hex 7FF). This allows for
    ;      a maximum scribner volume of 3201; equivalent to a maximum 
    ;      40' log with a diam of 41".  If one wishes to allow the handling 
    ;      of larger logs than this in the algorithm, then the maximum 
    ;      price must correspondingly be decreased. This makes handling 
    ;      old-growth a problem.
    ;  The (assembly language) bucking algorithm was not designed with 
    ;      old-growth in mind. In order to manage old-growth timber a 
    ;      massive redesign of the internal data handling is likely;
    ;      however, buck price is currently tracked to the tenths place in 
    ;      a form equal to price*10, and is only displayed to the nearest
    ;      dollar. BC price could be changed to only track to the nearest 
    ;      dollar, thus making the maximum price requirement 
    ;      ((price * (volume / 1000)) <= 65535). This would make possible 
    ;      (at the max price of 2047) a maximum scribner volume of 32015, 
    ;      and consequently some very large (or long) logs!
    ;
   ;load number to variable
    ;(C holds number pressed)
    ;(HL holds current variable value)
    ld b,0                   ;for clarity! (B is already zero from Mult8to16Bit)
    add hl,bc                   ;add current number to current variable value
    ld a,$07                    ;is number still within algorithm limits?
    cp h
    jp c,BCLP2_number_toobig   ;guess not, number is now too big
    ld d,h
    ld e,l
    pop hl                      ;address of variable
    ld (hl),e                   ;load variable with updated number
    inc hl
    ld (hl),d
    
    ;print number to screen
    ld a,c                      ;retrieve our number    
    add a,L0                    ;convert number to its display value
    call _putc                  ;print number to screen


    ;clear the message field
    ld hl,BCLP2_editing_message
    call menumessage
   
    ;return to getkey
    jp BCLP2_edit_getkey
BCLP2_number_toobig:           ;no, number is too big!
    pop hl  ;get this off the stack
    
    ld hl,toobig_message
    call menumessage        ;print message to screen
   
    jp BCLP2_clear             ;clear input and start over
BCLP2_number_length_nottoobig: ;yes, number is okay
    ;load number to variable 
    ld a,c                      ;a <- entered number
    add a,l                     ;add entered number to current length
    jp c,BCLP2_number_toobig   ;guess not, number is still too big
    pop hl                      ;hl <- address of length variable
    ld (hl),a                   ;load variable with updated length
    
    ;print number to screen
    ld a,c                      ;a <- entered number
    add a,L0                    ;convert number to its display value
    call _putc                  ;print number to screen

    ;clear the message field
    ld hl,BCLP2_editing_message
    call menumessage
    
    ;return to edit getkey
    jp BCLP2_edit_getkey
BCLP2_enter:
    call _cursoroff             ;turn blinking cursor off
    
    ;where was execution at when Enter key was pressed?
    ld a,(BCLP2_selection_location + 1)
    cp 2
    jp nc,BCLP2                ;'Enter' at Price, no checks needed
BCLP2_enter_length:            ;'Enter' at Length
    ;do we need to save anything? check edit status
    ld a,(BCLP2_editing)
    cp 0
    jp z,BCLP2

    ;get variable location
    ld a,(BCLP2_selection_location)  
    ld b,a
    ld hl,LCV
    call ArrayAccess_ne
BCLP2_enter_length_wrapup:
    ld a,(BCLP2_selection_location)   
    ld b,a
    ld hl,LCV
    call ArrayAccess_ne
    
    ;inc (hl)                    ;add trim to entered length

    ;signal that a length has changed
    ld hl,lengthschange
    ld (hl),1
    
    jp BCLP2
BCLP2_clear:
    call BCLP2_clearselection
    call BCLP2_clearelement
    jp BCLP2_edit_getkey
BCLP2_clearcriteria:
    call BCLP2_clearminmax_td
    call BCLP2_clearvolconstraint
    ret                         ;return to execution
BCLP2_clearminmax_td:
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,minmax_td
    call ArryAccessW_ne
    ld (hl),0
    inc hl
    ld (hl),0
    ret                         ;return to execution
BCLP2_clearvolconstraint:
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,vol_constrain
    call ArrayAccess_ne
    ld (hl),0
    ret                         ;return to execution
BCLP2_clearelement:
    call _cursoroff             ;turn blinking cursor off

    ;determine where execution was at
    ld a,(BCLP2_selection_location + 1)
    cp 1
    jp z,BCLP2_clearelement_length
    jp BCLP2_clearelement_price      
BCLP2_clearelement_length:    ;clear stored length
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,LCV
    call ArrayAccess_ne
    ld (hl),0
    ret                         ;return to execution
BCLP2_clearelement_price:     ;clear stored price
    ld a,(BCLP2_selection_location)
    ld b,a
    ld hl,prices                ;zero current log_dia array entry
    call ArryAccessW_ne
    ld (hl),0
    inc hl
    ld (hl),0
    ret                         ;return to execution    
BCLP2_done:
    ;delete all zero length pairs
    ld a,(LCV_size)
    ld b,a
    ld hl,LCV
    call ArrayAccess_ne
BCLP2_done_delete_loop: ;iterates through the length array
    push hl
    push bc
    ld a,(hl)
    cp 0
    jp nz,BCLP2_done_delete_loop_nodelete
    ld a,b
    ld (BCLP2_selection_location),a
    call BCLP2_delete
BCLP2_done_delete_loop_nodelete:
    pop bc
    pop hl
    
    dec hl
    dec b
    jp p,BCLP2_done_delete_loop

    ld a,(LCV_size)
    ld hl,BCLP2_selection_location
    ld (hl),a
BCLP2_done_check:
    ;check that LCV is populated
    ld a,(LCV_size)
    cp 0
    jp nz,BCLP2_done_finish
    ld a,(LCV)
    cp 0
    jp nz,BCLP2_done_finish
    ld ix,BCLP2_pleaseinputatleastonevalue_bigmessage
    call bigmessage
    call _getkey

    ld ix,inputsomething_message
    call BCLP2_drawscreen

    jp BCLP2_edit
BCLP2_done_finish:
    ;finish loading LCV
    ld hl,LCV
    ld a,(LCV_size)
    ld b,a
    inc b
    call ArrayAccess_ne
    ld (hl),255

    ;save updated data
    call save_data   
    
    ;clean up the screen
    call _cursoroff             ;turn blinking cursor off
    call _clrScrn

    ;check and prompt for stats reset
    ld a,(lengthschange)
    cp 0
    ret z                       ;return if no length changes
    ld ix,BCLP2_statskew_bigmessage
    call bigmessage
BCLP2_done_finish_statsreset_getkey:
    call _getkey
    cp kF4
    jp z,BCLP2_done_finish_statsreset_continue
    cp kF2
    jp z,BCLP2_done_finish_statsreset_continue
    jp BCLP2_done_finish_statsreset_getkey
BCLP2_done_finish_statsreset_continue:
    ld ix,BCLP2_resetstats_bigmessage
    call bigmessage
    call _getkey
    cp kF4
    jp z,BCLP2_done_finish_statsreset_reset
    cp kF2
    jp z,BCLP2_done_finish_end
    jp BCLP2_done_finish_statsreset_continue
BCLP2_done_finish_statsreset_reset:
    ld a,0                      ;entire matrix
    call StatDataInit

    ;return
    ret

BCLP2_done_finish_end:
    ;zero out the lengthschange tracking variable and return
    ld a,0
    ld (lengthschange),a

    ;return
    ret   



    

address_after_prog: $
