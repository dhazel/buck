

;============================================================
; Handoff_BCK23 -- Hands execution off to the external 
;           bucking algorithm, BCK23 (the bucking core)
;  input: none
;  output: a different assembly program (BCK23) is called
;           and execution is handed off to it
;  affects: assume everthing
;  total: 114b
;  tested: no
;============================================================
    jp Handoff_BCK23 ;just in case!
Handoff_BCK23_bigmessage_text: .db "The Bucking core       executable is not    present on this      calculator",0
Handoff_BCK23_bigmessage: .dw Handoff_BCK23_bigmessage_text,okay_text,okay_text

Handoff_BCK23:
    ;check for existance of BCK23
    ld hl,pname_BCBuckingAlgorithm-1      ;copy anything before string name 
                                            ; for type byte
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym to see if variable
                                            ; exists
    ;if not present, display bigmessage and return
    jp c,Handoff_BCK23_nonexistant

    ;write data over to BCK23
    ld hl,pname_BCBuckingAlgorithm
    call copyover_data
    ld hl,pname_BCBuckingAlgorithm
    call copyover_volatile
    
    ;BEHOLD! the handoff!
    call _exec_assembly             ;exec assembly program named in op1

    ;return
    ret
Handoff_BCK23_nonexistant:
    ;display big message, wait for keypress and return
    ld ix,Handoff_BCK23_bigmessage
    call bigmessage
    call _getkey
    ret

