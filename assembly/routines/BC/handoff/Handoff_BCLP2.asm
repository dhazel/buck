

;============================================================
; Handoff_BCLP2 -- Hands execution off to the external 
;           length and price editor, BCLP2
;  input: none
;  output: a different assembly program (BCLP2) is called
;           and execution is handed off to it
;  affects: assume everthing
;  total: 114b
;  tested: yes
;============================================================
    jp Handoff_BCLP2 ;just in case!
Handoff_BCLP2_bigmessage_text: .db "The Length and Price   editor is not        present on this      calculator",0
Handoff_BCLP2_bigmessage: .dw Handoff_BCLP2_bigmessage_text,okay_text,okay_text

Handoff_BCLP2:
    ;check for existance of BCLP2
    ld hl,pname_BCLengthPriceEditor-1      ;copy anything before string name 
                                            ; for type byte
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym to see if variable
                                            ; exists
    ;if not present, display bigmessage and return
    jp c,Handoff_BCLP2_nonexistant

    ;write data over to BCLP2
    ld hl,pname_BCLengthPriceEditor
    call copyover_data
    
    ;BEHOLD! the handoff!
    call _exec_assembly             ;exec assembly program named in op1

    ;return
    ret
Handoff_BCLP2_nonexistant:
    ;display big message, wait for keypress and return
    ld ix,Handoff_BCLP2_bigmessage
    call bigmessage
    call _getkey
    ret

