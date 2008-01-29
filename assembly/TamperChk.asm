

;* TamperChk -- the tamper/piracy checking routine
;*******************************************************************************
#ifndef DEBUG

;============================================================
; TamperChk -- This is the tamper checking routine. It writes
;               and checks a hidden variable stored with 
;               version and ID number information.
;  input:   TamperChk_ID_name
;           TamperChk_ID_number_start
;           TamperChk_ID_number_end
;           TamperChk_firstrun
;           the TIOS variable %btcv
;  output:  the TIOS variable %btcv
;           permission to use program and/or full functionality
;  affects: assume everything 
;  total: 191b
;  tested: no
;============================================================
    jp TamperChk ;just in case!
TamperChk_ID_name: .db 8,_version_ID_name   ;buck tamper check external variable
                                            ; (versioned for coexistance)
                                            ; (no longer than 8 digits)
TamperChk_ID_number_start: .db _version_ID_code  ;this should allow  
                                                 ;  differentiation between 
                                                 ;  builds
TamperChk_ID_number_end:
TamperChk_ID_check_storage: .db "------";this is where external variable data
                                        ; will be copied for comparison
TamperChk_tamperfound_text: .db "Tampering detected. Program will exit",0
TamperChk_tamperfound_bigmessage: .dw TamperChk_tamperfound_text,okay_text,okay_text

TamperChk:
    ;check for presence of all programs (simple checks for now)
    ld hl,pname_MainBuckingCalculator-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCLengthPriceEditor-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCSetup-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCBuckingAlgorithm-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCStatisticsProcessor-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCStatisticsViewer-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCStatisticsUndoer-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing
    ld hl,pname_BCStatisticsMillChooser-1
        rst 20h                             ;call _Mov10toOP1
        rst 10h                             ;call _FindSym
        jp c,TamperChk_tamperfound          ;goto error if program is missing

    ;check validity of program; if first-run, then install versioning data
    ld a,(TamperChk_firstrun_status)
    cp 0
    jp z,TamperChk_laterrun
TamperChk_firstrun:
    ;reset firstrun status
    ld a,0
    ld (TamperChk_firstrun_status),a
    call save_data                      ;save data

    ;create external ID name hidden variable
    ld hl,TamperChk_ID_name-1       ;copy anything before string name for
                                    ; type byte
        rst 20h                     ;call _Mov10toOP1
        rst 10h                     ;call _FindSym to see if variable
                                    ; exists
    call nc,_delvar                 ;delete variable if it exists
                                    ;all necessary info still preserved
    ld hl,TamperChk_ID_number_end-TamperChk_ID_number_start
                                    ;minus start from end of
                                    ; string data so result is length
                                    ; of string
    call _createstrng               ;$472f  create string

    ;load external variable with ID number
    call _ex_ahl_bde                ;$45f3  ABS bde & ahl swapped
    call _ahl_plus_2_pg3            ;$4c3f  increase ABS ahl by two
    call _set_abs_dest_addr         ;$5285  set that as destination for
                                    ; block copy
    xor a                           ;AKA ld a,0
    ld hl,TamperChk_ID_number_start ;hl points to TamperChk_ID_number_start
                                    ;address of string data is in relation
                                    ; to 16 bit and ram page
    call _set_abs_src_addr          ;$4647  set that as source for
                                    ; block copy
    xor a                           ;AKA ld a,0 -it's on already swapped
                                    ; in page (0)
                                    ;length of string data
    ld hl,TamperChk_ID_number_end-TamperChk_ID_number_start
    call _set_mm_num_bytes          ;$464f  set # of bytes to copy in
                                    ; block copy
    jp _mm_ldir                     ;$52ed  ABS block copy
                                    ;we jump instead of calling
                                    ; and returning this way we just use
                                    ; _mm_ldir's ret as ours
                                    ;saves 1 byte
    ret   ;return (just in case!)
TamperChk_laterrun:
    ;check for external ID name hidden variable
    ld hl,TamperChk_ID_name-1       ;copy anything before string name for
                                    ; type byte
        rst 20h                     ;call _Mov10toOP1
        rst 10h                     ;call _FindSym to see if variable
                                    ; exists
    jp c,TamperChk_tamperfound      ;variable does not exist, tamper suspected

    ;load contents of hidden variable into internal temp storage
    call _ex_ahl_bde                ;$45f3  ABS bde & ahl swapped
    call _ahl_plus_2_pg3            ;$4c3f  increase ABS ahl by two
    call _set_abs_src_addr          ;$4647  set that as source for
                                    ; block copy
    xor a                           ;AKA ld a,0
    ld hl,TamperChk_ID_check_storage;hl points to TamperChk_ID_check_storage
                                    ;address of string data is in relation
                                    ; to 16 bit and ram page
    call _set_abs_dest_addr         ;$5285  set that as destination for
                                    ; block copy
    xor a                           ;AKA ld a,0 -it's on already swapped
                                    ; in page (0)
                                    ;length of string data
    ld hl,TamperChk_ID_number_end-TamperChk_ID_number_start
    call _set_mm_num_bytes          ;$464f  set # of bytes to copy in
                                    ; block copy
    call _mm_ldir                   ;$52ed  ABS block copy

    ;check contents of hidden variable
    ld b,TamperChk_ID_number_end-TamperChk_ID_number_start
    dec b           ;index issues once again
    ld hl,TamperChk_ID_check_storage
    ld de,TamperChk_ID_number_start
TamperChk_datacheck_loop:
    ld a,(de)
    cp (hl)
    jp nz,TamperChk_tamperfound
    inc hl
    inc de

    dec b
    jp p,TamperChk_datacheck_loop
    ret                             ;return, no tampering detected
TamperChk_tamperfound:
    ;display tamper message
    ld ix,TamperChk_tamperfound_bigmessage
    call bigmessage
    call _getkey
    call AboutBuck
    call _clrScrn
    call _homeup
    call _jforcecmdnochar ;<-- this is a simple way to exit the program

    ret         ;return (just in case!)

#endif
