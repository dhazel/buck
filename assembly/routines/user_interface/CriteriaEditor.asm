

;============================================================
; CriteriaEditor -- This is the log criteria editor, it displays a
;           length-price pair along with its top diameter criteria
;           and allows simple editing of those criteria. This 
;           editor can also traverse the LCV on its own and
;           view/edit the criteria of any length-price pair.
;  input: LCV (the lengths check array)
;         prices (the corresponding prices array)
;         minmax_td (the corresponding top diameter criteria array)
;         LCV_size
;         A = LCV index for requested log
;  output: interactive editing of log criteria
;  affects: TBA
;  total: 1025b
;  tested: yes
;============================================================
    jp CriteriaEditor ;just in case!
CriteriaEditor_wipe_bigmessage_text: .db "Remove all criteria   for this log?",0
CriteriaEditor_wipe_bigmessage: .dw CriteriaEditor_wipe_bigmessage_text,cancel_text,okay_text
CriteriaEditor_header_text: .db "Criteria------------",0
CriteriaEditor_mintopdiam_text: .db "Min Top Diam:",0
CriteriaEditor_maxtopdiam_text: .db "Max Top Diam:",0
CriteriaEditor_volconstraint_text: .db "Min Volume:",0
CriteriaEditor_selection: .db 0     ;the current selection (row) we are on
CriteriaEditor_index: .db 0         ;the current array index we are on
CriteriaEditor_selection_col: .db 0     ;the current column selection we are on
CriteriaEditor_LCV_traversal: .db 1 ;are we allowed to traverse the LCV?
CriteriaEditor_menu_data:
    .db 6,1,4,"EXIT"
    .db 34,1,1,LsqDown
    .db 55,1,4,"WIPE"
    .db 88,1,1,LsqUp
    .db 108,1,4,"DONE"
    ; NOTE: if the up and down arrows are not displayed, then that functionality
    ;   is unavailable
#define _CriteriaEditor_menu_data_downarrowoffset 8
#define _CriteriaEditor_menu_data_uparrowoffset 19

#define _CriteriaEditor_td_column 15
#define _CriteriaEditor_vol_column1 12
#define _CriteriaEditor_vol_column2 15
#define _CriteriaEditor_selection1_row 3
#define _CriteriaEditor_selection2_row 4
#define _CriteriaEditor_selection3_row 5
CriteriaEditor_drawscreen: ;draws the screen
    ; input: CriteriaEditor_index = LCV index for requested log
    ;        IX = pointer to message text
    ;        LCV
    ;        prices
    ;        minmax_td
    ;
    push ix         ;pointer to message text

    ;draw the menu
    ld hl,CriteriaEditor_menu_data
    call menu

    ;draw the menu message
    call clearwindow
    pop hl
    call menuhighmessage

    ;display the header text
    call _homeup
        ld a,2
    ld (_curCol),a
    ld a,Lblock
    ;call _putc
    ;call _putc
    call CriteriaEditor_displaylengthprice

    ;display the selected length-price pair
    call _newline
    ld hl,CriteriaEditor_header_text
    call _puts

    ;display min and max top diam prompts
        ld a,_CriteriaEditor_selection1_row
    ld (_curRow),a
        ld a,0
    ld (_curCol),a
    ld hl,CriteriaEditor_mintopdiam_text
    call _puts
        ld a,_CriteriaEditor_selection2_row
    ld (_curRow),a
        ld a,0
    ld (_curCol),a
    ld hl,CriteriaEditor_maxtopdiam_text
    call _puts

    ;display min and max top diam prompts
        ld a,_CriteriaEditor_selection3_row
    ld (_curRow),a
        ld a,0
    ld (_curCol),a
    ld hl,CriteriaEditor_volconstraint_text
    call _puts

    ;display editable entry 1
    ld a,(CriteriaEditor_selection)
    cp 0
    jp nz,CriteriaEditor_overhighlight1
    set textinverse,(iy+textflags)
CriteriaEditor_overhighlight1:
    ld a,(CriteriaEditor_index) ;A <- LCV index
    sla a                   ;the elements are bytes, but stored in pairs
    ld c,a

        ld a,_CriteriaEditor_selection1_row
    ld (_curRow),a
        ld a,_CriteriaEditor_td_column
    ld (_curCol),a
    ld ix,minmax_td
    ld a,2                          ;element/no print mode
    call PrintArrayElm_drawscreen
    res textinverse,(iy+textflags)

    ;display editable entry 2
    ld a,(CriteriaEditor_selection)
    cp 1
    jp nz,CriteriaEditor_overhighlight2
    set textinverse,(iy+textflags)
CriteriaEditor_overhighlight2:
    inc c                   ;C == LCV index

        ld a,_CriteriaEditor_selection2_row
    ld (_curRow),a
        ld a,_CriteriaEditor_td_column
    ld (_curCol),a
    ld ix,minmax_td        ;this does need repeating
    ld a,2                          ;element/no print mode
    call PrintArrayElm_drawscreen
    res textinverse,(iy+textflags)

    ;display editable entry 3, row 1
    ld a,(CriteriaEditor_selection)
    cp 2
    jp nz,CriteriaEditor_overhighlight3
    ld a,(CriteriaEditor_selection_col)
    cp 0
    jp nz,CriteriaEditor_overhighlight3
    set textinverse,(iy+textflags)
CriteriaEditor_overhighlight3:
    ld a,(CriteriaEditor_index) ;A <- LCV index
    ld c,a

        ld a,_CriteriaEditor_selection3_row
    ld (_curRow),a
        ld a,_CriteriaEditor_vol_column1
    ld (_curCol),a
    ld ix,vol_constrain
    ld a,0                          ;yes/no print mode
    call PrintArrayElm_drawscreen

    ;reset the font to normal display
    res textinverse,(iy+textflags)

    ;display editable entry 3, row 2
    ld a,(CriteriaEditor_selection)
    cp 2
    jp nz,CriteriaEditor_overhighlight4
    ld a,(CriteriaEditor_selection_col)
    cp 1
    jp nz,CriteriaEditor_overhighlight4
    set textinverse,(iy+textflags)
CriteriaEditor_overhighlight4:
        ld a,_CriteriaEditor_selection3_row
    ld (_curRow),a
        ld a,_CriteriaEditor_vol_column2
    ld (_curCol),a
    ld hl,(vol_constraint_percent)
    xor a
    ld h,0
    call _dispAHL
    ld a,Lpercent
    call _putc

    ;reset the font to normal display
    res textinverse,(iy+textflags)

    ;return
    ret 

CriteriaEditor_displaylengthprice: ;displays a length-price pair
    ; inputs: CriteriaEditor_index = LCV index for requested pair
    ;

    ;print LCV element
    ld a,(CriteriaEditor_index)
    ld c,a
    push bc             ;save BC for later
    ld ix,LCV
    ld a,1                          ;element print mode
    call PrintArrayElm_drawscreen

    ;print foot symbol
    ld a,Lapostrophe
    call _putc

    ;move two spaces to the right
    ld hl,_curCol
    inc (hl)
    inc (hl)

    ;print the dollar symbol
    ld a,Ldollar
    call _putc

    ;print the prices element
    pop bc
    ld ix,prices
    call PrintArrayLWElm

    ret 

CriteriaEditor_clearselection: ;clears the display of the current selection
    ; inputs:  CriteriaEditor_selection
    ;   NOTE: returns the cursor to the beginning of the selection field
    ;
    ld a,(CriteriaEditor_selection)
    cp 0
    jp nz,CriteriaEditor_clearselection_over1
        ld a,_CriteriaEditor_td_column
    ld (_curCol),a
        ld a,_CriteriaEditor_selection1_row
    jp CriteriaEditor_clearselection_write
CriteriaEditor_clearselection_over1:
    cp 1
    jp nz,CriteriaEditor_clearselection_over2
        ld a,_CriteriaEditor_td_column
    ld (_curCol),a
        ld a,_CriteriaEditor_selection2_row
    jp CriteriaEditor_clearselection_write
CriteriaEditor_clearselection_over2:
    cp 2
    jp nz,CriteriaEditor_clearselection_write
        ld a,_CriteriaEditor_vol_column1
    ld (_curCol),a
        ld a,_CriteriaEditor_selection3_row
CriteriaEditor_clearselection_write:
    ld (_curRow),a

    ld hl,(_curRow)     ;save initial cursor location
    push hl

    ld hl,clearselection_text
    call _puts

    pop hl              ;reload initial cursor location
    ld (_curRow),hl

    ;return
    ret 
    
CriteriaEditor_clear: ;clears the selected criteria element
    ; input:    CriteriaEditor_index
    ;           CriteriaEditor_selection
    ;
    ;determine address of top diameter criteria pair
    ld a,(CriteriaEditor_index)
    ld b,a
    ld hl,minmax_td
    call ArryAccessW_ne

    ;determine which criteria of the pair is selected to clear
    ld a,(CriteriaEditor_selection)
    cp 0
    jp nz,CriteriaEditor_clear_overselection1
    jp CriteriaEditor_clear_overselection2
CriteriaEditor_clear_overselection1:
    cp 1
    jp nz,CriteriaEditor_clear_overselection2
    inc hl
CriteriaEditor_clear_overselection2:
    cp 2
    jp z,CriteriaEditor_clear_selection3
    jp CriteriaEditor_clear_finish
CriteriaEditor_clear_selection3:
    ;determine address of volume criteria element
    ld a,(CriteriaEditor_index)
    ld b,a
    ld hl,vol_constrain
    call ArrayAccess_ne
CriteriaEditor_clear_finish:
    ;clear the top diameter criteria selection element
    ld (hl),0

    ;return
    ret 

CriteriaEditor:
    ld (CriteriaEditor_index),a ;save the current index for stateful operation

    ;check for top and bottom of LCV and turn the menu arrows off
    ld a,(CriteriaEditor_LCV_traversal)
    cp 0
    jp nz,CriteriaEditor_topandbottomcheck
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset
    ld (hl),0
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset
    ld (hl),0
    jp CriteriaEditor_restart
CriteriaEditor_topandbottomcheck:
    ld a,(CriteriaEditor_index)
    ld b,a
    ld a,(LCV_size)
    cp b
    ret c                       ;if we are beyond LCV end then return and do nothing
    jp nz,CriteriaEditor_keepuparrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset
    ld (hl),0    
CriteriaEditor_keepuparrow:
    ld a,0
    cp b
    jp nz,CriteriaEditor_keepdownarrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset
    ld (hl),0    
CriteriaEditor_keepdownarrow:
CriteriaEditor_restart:         ;this is in case I need a label for restart
    ;draw the screen
    ld ix,empty_text
    call CriteriaEditor_drawscreen

    ;get keypress input
CriteriaEditor_getkey:
    call _getkey                ;wait for a keypress
    cp kClear
    jp z,CriteriaEditor_call_clear
    cp kExit
    jp z,CriteriaEditor_done
    cp kUp
    jp z,CriteriaEditor_up
    cp kDown
    jp z,CriteriaEditor_down
    cp kF5
    jp z,CriteriaEditor_done
    ld b,a
    ld a,(CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset)
    cp 1
    ld a,b ;does not affect the flags
    jp nz,CriteriaEditor_getkey_overuparrow
    cp kF4
    jp z,CriteriaEditor_nextLCV
CriteriaEditor_getkey_overuparrow:
    cp kF3
    jp z,CriteriaEditor_wipe
    ld b,a
    ld a,(CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset)
    cp 1
    ld a,b ;does not affect the flags
    jp nz,CriteriaEditor_getkey_overdownarrow
    cp kF2
    jp z,CriteriaEditor_prevLCV
CriteriaEditor_getkey_overdownarrow:
    cp kF1
    jp z,CriteriaEditor_done
    cp kDel
    jp z,CriteriaEditor_call_clear
    ld b,a
    ld a,(CriteriaEditor_selection)
    cp 2
    ld a,b
    jp z,CriteriaEditor_getkey_volume
    cp kEnter      
    jp z,CriteriaEditor_edit
    cp k0
    jp c,CriteriaEditor_getkey
    cp k9+1
    jp c,CriteriaEditor_numberedit
    jp CriteriaEditor_getkey
CriteriaEditor_getkey_volume:
    cp kLeft
    jp z,CriteriaEditor_volleft
    cp kRight
    jp z,CriteriaEditor_volright
    ld b,a
    ld a,(CriteriaEditor_selection_col)
    cp 1
    ld a,b
    jp z,CriteriaEditor_getkey_volume_col2
    cp kEnter      
    jp z,CriteriaEditor_voltoggle
    jp CriteriaEditor_getkey
CriteriaEditor_getkey_volume_col2:
    cp kEnter      
    jp z,CriteriaEditor_volset
    jp CriteriaEditor_getkey
CriteriaEditor_volset:
    ;call the volume percent editor
    call VolPercEd
    jp CriteriaEditor_restart
CriteriaEditor_volleft:
    ld a,0
    ld (CriteriaEditor_selection_col),a
    jp CriteriaEditor_restart
CriteriaEditor_volright:
    ld a,1
    ld (CriteriaEditor_selection_col),a
    jp CriteriaEditor_restart
CriteriaEditor_voltoggle:
    ;determine address of volume criteria element
    ld a,(CriteriaEditor_index)
    ld b,a
    ld hl,vol_constrain
    call ArrayAccess_ne
    ld a,(hl)
    xor 1                   ;toggle between 0 and 1
    ld (hl),a
    jp CriteriaEditor_restart
CriteriaEditor_up:
    ld hl,CriteriaEditor_selection
    ld a,0
    cp (hl)
    jp z,CriteriaEditor_getkey
    dec (hl)
    jp CriteriaEditor_restart
CriteriaEditor_down:
    ld hl,CriteriaEditor_selection
    ld a,2
    cp (hl)
    jp z,CriteriaEditor_getkey
    inc (hl)
    jp CriteriaEditor_restart
CriteriaEditor_call_clear:
    call CriteriaEditor_clear
    jp CriteriaEditor_restart
CriteriaEditor_wipe:
    ;ask if the user really wants to do this
    ld ix,CriteriaEditor_wipe_bigmessage
    call bigmessage
    call _getkey
    cp kF4
    jp nz,CriteriaEditor_restart

    ;wipe out all criteria for this length-price pair
    ld a,(CriteriaEditor_index)
    ld b,a
    ld hl,minmax_td
    call ArryAccessW_ne
    ld (hl),0
    inc hl
    ld (hl),0
    ld hl,vol_constrain
    call ArrayAccess_ne
    ld (hl),0

    ;reload the editor
    jp CriteriaEditor_restart
CriteriaEditor_nextLCV:
    ;(it is not necessary to check for LCV end, the arrow settings control this)
    ;increment the index
    ld hl,CriteriaEditor_index
    inc (hl)

    ;check for last index, if so remove arrow
    ld a,(LCV_size)
    cp (hl)
    jp nz,CriteriaEditor_nextLCV_overremovearrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset
    ld (hl),0
CriteriaEditor_nextLCV_overremovearrow:
    ;turn on the downarrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset
    ld (hl),1

    ;reload
    jp CriteriaEditor_restart
CriteriaEditor_prevLCV:
    ;(it is not necessary to check for LCV end, the arrow settings control this)
    ;decrement the index
    ld hl,CriteriaEditor_index
    dec (hl)

    ;check for lowest index, if so remove arrow
    ld a,0
    cp (hl)
    jp nz,CriteriaEditor_prevLCV_overremovearrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset
    ld (hl),0
CriteriaEditor_prevLCV_overremovearrow:
    ;turn on the uparrow
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset
    ld (hl),1

    ;reload
    jp CriteriaEditor_restart
CriteriaEditor_numberedit:
    push af
    call clearmenu
    ld hl,BCLP2_editing_message
    call menumessage
    call CriteriaEditor_clearselection
    pop af
    ld hl,_maximum_top_diameter
    call InputInt
    jp c,CriteriaEditor_edit_toobig
    jp z,CriteriaEditor_restart
    jp CriteriaEditor_edit_saveinput
CriteriaEditor_edit:
    call clearmenu
    ld hl,BCLP2_editing_message
    call menumessage
    call CriteriaEditor_clearselection
    ld a,0
    ld hl,_maximum_top_diameter
    call InputInt
    jp c,CriteriaEditor_edit_toobig
    jp z,CriteriaEditor_restart
    jp CriteriaEditor_edit_saveinput
CriteriaEditor_edit_toobig:
    ld hl,toobig_message
    call menumessage
    call _getkey
    jp CriteriaEditor_edit
CriteriaEditor_edit_saveinput:
    ld a,(CriteriaEditor_index)
    ld b,a
    ld hl,minmax_td
    call ArryAccessW_ne
    ld a,(CriteriaEditor_selection)
    cp 0
    jp nz,CriteriaEditor_edit_saveinput_overselection1
    jp CriteriaEditor_edit_saveinput_overselection2
CriteriaEditor_edit_saveinput_overselection1:
    cp 1
    jp nz,CriteriaEditor_edit_saveinput_overselection2
    inc hl
CriteriaEditor_edit_saveinput_overselection2:
    ld (hl),e           ;DE will not exceed 255 (we only need to save E)
    jp CriteriaEditor_restart   ;reload
CriteriaEditor_done:
    ;turn the arrows back on
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_uparrowoffset
    ld (hl),1
    ld hl,CriteriaEditor_menu_data + _CriteriaEditor_menu_data_downarrowoffset
    ld (hl),1
    
    ;syncronize with BCLP2
    ld a,(CriteriaEditor_index)
    ld hl,BCLP2_selection_location
    ld (hl),a

    ;save the data
    ld a,2                  ;volume constraint data only
    call StatDataInit

    ;return
    ret 

