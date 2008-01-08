    

;* Buck Test Functions -- unnecessary for normal program operation
;******************************************************************************

#ifdef DEBUG

;============================================================
; TestPrints -- displays all output arrays generated by
;               the bucking algorithm
;  input:   p1, p2, Lf, Lf2, v1, v2, td1, td2  
;  output:  output printed to screen
;  affects: assume everything
;  total: 254b/1036t (excluding func calls, including ret)
;  tested: yes
;============================================================
    jp TestPrints_over_testprints
TestPrints:
    call _newline
    call _getkey
    jp TestPrints_over_testprints_data
price_array_text:  .db "Prices:",0
length_array_text: .db "Lengths:",0
volume_array_text: .db "Volumes:",0
diam_array_text:   .db "Diams:",0
separator_text:    .db "------",0
TestPrints_over_testprints_data:

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,user_l
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,user_p
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,user_v
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,separator_text
    call _puts
    call _newline

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,Lf
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,p1
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,v1
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,diam_array_text
    call _puts
    call _newline
    ld ix,td1
    ld b,5
    call PrintArray
    call _newline
    call _getkey
 
    ld hl,separator_text
    call _puts
    call _newline

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,Lf2
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,p2
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,v2
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,diam_array_text
    call _puts
    call _newline
    ld ix,td2
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ret
TestPrints_over_testprints:



;============================================================
; VarDump -- for those really elusive bugs; 
;               displays all of the important Buck algorithm
;               data, and exits the program
;  input:   status_iterator, Li, td, it, p, v  
;  output:  the inputs printed to screen
;  affects: assume everything
;  total: 187b (including ret)
;  tested: yes
;============================================================
    jp VarDump  ;just in case
VarDump_status_iterator_text: .db "s iterator:",0
VarDump_Li_text: .db "Li:",0
VarDump_td_text: .db "td:",0
VarDump_it_text: .db "it:",0
VarDump_p_text: .db "p:",0
VarDump_v_text: .db "v:",0
VarDump:
    call clearwindow
    call clearmenu
    call _homeup

    ld hl,VarDump_status_iterator_text
    call _puts
    ld hl,status_iterator
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _newline
    
    ld hl,VarDump_Li_text
    call _puts
    ld ix,Li
    ld b,6
    call PrintArray
    call _newline
    
    ld hl,VarDump_td_text
    call _puts
    ld ix,td
    ld b,6
    call PrintArray
    call _newline

    ld hl,VarDump_it_text
    call _puts
    ld ix,it
    ld b,6
    call PrintArray
    call _getkey
    cp kExit
    jp z,VarDump_exit
    call _newline
        
    ld hl,VarDump_p_text
    call _puts
    ld ix,p
    ld b,6
    call PrintArrayW
    call _newline
    call _getkey
    cp kExit
    jp z,VarDump_exit
    
    ld hl,VarDump_v_text
    call _puts
    ld ix,v
    ld b,6
    call PrintArrayW
    
VarDump_exit:
    call _getkey
    cp kMore
    call z,PrintErrors
    call _getkey
    cp kMore
    jp z,VarDump
    call _dispDone
    call _jforcecmdnochar
    
    ret


            
;============================================================
; Gotcha -- for debugging, place a break on this label's 
;               address and call it on any suspicious 
;               conditions
;   input: none
;   output: none
;   affects: none
;   total: N/A
;   tested: yes of course
;============================================================
Gotcha:
    ret
    
            

;============================================================
; BugCatcher -- when called, pauses program and prints a
;                   message to the screen; thus, allowing 
;                   breakpoints to be added and memory to be
;                   observed (within an emulator/debugger)
;  input: IX = pointer to the message text
;  output: message printed to screen, program pause
;  affects: Assume all registers; place BugCatcher within a 
;               push/pop environment similar to the one 
;               commented within the BugCatcher code below
;  total: 22b/129t (excluding called functions, including ret)
;  tested: yes
;============================================================
BugCatcher:
;    push af
;    push bc
;    push de
;    push hl
    
    push ix
    call _clrScrn
    ld hl,0
    ld (_curRow),hl
    pop hl
    call _puts
    call _getkey
    call _newline
    
;    pop hl
;    pop de
;    pop bc
;    pop af

    ret


    jp BugCatcher_overtest_templates
;================================================================
;TESTING TEMPLATES
;================================================================

;\/\/\/BugCatcher
;    ;AFFECTS: IX -> undefined
;    
;    jp overbugcatch1_text
;bugcatch1_text: .db "bugcatch1",0
;overbugcatch1_text:
;    
;    push af
;    push bc
;    push de
;    push hl
;    
;    ;-----------
;    ;condition checks
;    ld a,1                  ;only trigger when s == ?
;    cp b
;    jp nz,bugcatch1_skip
;    ld hl,Li
;    call ArrayAccess
;    ld a,41                 ;only trigger when Li[s] == ?
;    cp (hl)
;    jp nz,bugcatch1_skip
;    dec hl                  ;only trigger when Li[s-1] == ?
;    ld a,37
;    cp (hl)
;    jp nz,bugcatch1_skip
;    
;bugcatch1_call:
;    ;if conditions met
;    ld ix,bugcatch1_text
;    call BugCatcher
;    ;-----------
;bugcatch1_skip:
;    
;    pop hl
;    pop de
;    pop bc
;    pop af
;/\/\/\/\/\/\/\/\

;\/\/\/TESTING
    ;place test instructions here
;/\/\/\/\/\/\/

;================================================================
BugCatcher_overtest_templates:

#endif



