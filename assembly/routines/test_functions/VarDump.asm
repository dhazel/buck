

#ifdef DEBUG

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


#endif
