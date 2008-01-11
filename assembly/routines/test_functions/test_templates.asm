


#ifdef DEBUG

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

