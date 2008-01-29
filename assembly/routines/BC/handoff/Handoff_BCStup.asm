

;============================================================
; Handoff_BCStup -- Hands execution off to the external 
;           setup editor, BCStup
;  input: none
;  output: a different assembly program (BCStup) is called
;           and execution is handed off to it
;  affects: assume everthing
;  total: 98b
;  tested: yes
;============================================================
    jp Handoff_BCStup ;just in case!
Handoff_BCStup_bigmessage_text: .db "The Setup module is    not present on       this calculator",0
Handoff_BCStup_bigmessage: .dw Handoff_BCStup_bigmessage_text,okay_text,okay_text

Handoff_BCStup:
#ifndef DEBUG
    ;check for existance of BCStup
    ld hl,pname_BCSetup-1     ;copy anything before string name 
                                            ; for type byte
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym to see if variable
                                            ; exists
    ;if not present, display bigmessage and return
    jp c,Handoff_BCStup_nonexistant

    ;write data over to BuckLP2
    ld hl,pname_BCSetup
    call copyover_data
    
    ;BEHOLD! the handoff!
    call _exec_assembly             ;exec assembly program named in op1

    ;return
    ret
Handoff_BCStup_nonexistant:
#endif
    ;display big message, wait for keypress and return
    ld ix,Handoff_BCStup_bigmessage
    call bigmessage
    call _getkey
    ret

