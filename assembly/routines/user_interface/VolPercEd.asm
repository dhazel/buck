


;============================================================
; VolPercEd -- This is the volume percentage editor. It edits the minimum 
;           volume setting used by the volume constraint framework.
;  input: vol_constraint_percent
;  output: interactive editing of the data field
;  affects: TBA
;  total: 351b
;  tested: yes
;============================================================
    jp VolPercEd ;just in case!
VolPercEd_header_text: .db "Minimum volume        percentage. This is  a shared value.",0
VolPercEd_volperc_text: .db "Min Volume:",0
VolPercEd_menu_data:
    .db 4,1,4,"BACK"
    .db 34,0,1," "
    .db 55,0,1," "
    .db 88,0,1," "
    .db 108,1,4,"DONE"

#define _VolPercEd_selection_row 5
#define _VolPercEd_selection_col 13
VolPercEd_drawscreen: ;draws the screen
    ; input: IX = pointer to message text
    ;        vol_constraint_percent
    ;
    push ix         ;pointer to message text

    ;draw the menu
    ld hl,VolPercEd_menu_data
    call menu

    ;draw the menu message
    call clearwindow
    pop hl
    call menuhighmessage

    ;display the header text
    call _homeup
    ld hl,VolPercEd_header_text
    call _puts

    ;display min and max top diam prompts
        ld a,_VolPercEd_selection_row
    ld (_curRow),a
        ld a,0
    ld (_curCol),a
    ld hl,VolPercEd_volperc_text
    call _puts

    ;display editable entry 
    set textinverse,(iy+textflags)

        ld a,_VolPercEd_selection_row
    ld (_curRow),a
        ld a,_VolPercEd_selection_col
    ld (_curCol),a
    ld hl,(vol_constraint_percent)
    xor a
    ld h,0
    call _dispAHL
    res textinverse,(iy+textflags)

    ;display percent symbol
        ld a,19
    ld (_curCol),a
    ld a,Lpercent
    call _putc

    ;return 
    ret


VolPercEd_clearselection: ;clears the display of the current selection
    ; inputs:  none
    ;   NOTE: returns the cursor to the beginning of the selection field
    ;
        ld a,_VolPercEd_selection_col
    ld (_curCol),a
        ld a,_VolPercEd_selection_row
    ld (_curRow),a

    ld hl,(_curRow)     ;save initial cursor location
    push hl

    ld hl,clearselection_text
    call _puts

    pop hl              ;reload initial cursor location
    ld (_curRow),hl

    ;return
    ret 

VolPercEd_clear: ;clears the vol_constraint_percent
    ; input:    vol_constraint_percent
    ;
    ld hl,vol_constraint_percent
    ld (hl),0
    ret

VolPercEd:
    ;draw the screen
    ld ix,empty_text
    call VolPercEd_drawscreen

    ;get keypress input
VolPercEd_getkey:
    call _getkey                ;wait 
    cp kClear
    jp z,VolPercEd_call_clear
    cp kExit
    jp z,VolPercEd_done
    cp kF5
    jp z,VolPercEd_done
    cp kF1
    jp z,VolPercEd_done
    cp kDel
    jp z,VolPercEd_call_clear
    cp kEnter      
    jp z,VolPercEd_edit
    cp k0
    jp c,VolPercEd_getkey
    cp k9+1
    jp c,VolPercEd_numberedit
    jp VolPercEd_getkey
VolPercEd_call_clear:
    call VolPercEd_clear
    jp VolPercEd
VolPercEd_done:
    ld a,2                  ;volume constraint data only
    call StatDataInit
    ret
VolPercEd_edit:
    call clearmenu
    ld hl,BCLP2_editing_message
    call menumessage
    call VolPercEd_clearselection
    ld a,0                          ;no initial keypress
    ld hl,99                        ;maximum limit for input number
    call InputInt
    jp c,VolPercEd_edit_toobig
    jp z,VolPercEd
    jp VolPercEd_edit_save
VolPercEd_numberedit:
    push af
    call clearmenu
    ld hl,BCLP2_editing_message
    call menumessage
    call VolPercEd_clearselection
    pop af                          ;A <- initial keypress value
    ld hl,99                        ;maximum limit for input number
    call InputInt
    jp c,VolPercEd_edit_toobig
    jp z,VolPercEd
    jp VolPercEd_edit_save
VolPercEd_edit_save:
    ld hl,vol_constraint_percent
    ld (hl),e
    jp VolPercEd
VolPercEd_edit_toobig:
    ld hl,toobig_message
    call menumessage
    call _getkey
    jp VolPercEd_edit



