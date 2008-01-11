

#ifdef DEBUG

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


#endif



