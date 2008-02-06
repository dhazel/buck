

;===============================================================================
; StringCreate -- creates a TIOS string variable
;  input:   HL == pointer to string name (length initialized)
;           DE == pointer to string data (zero terminated)
;           if A =! 1, default operation; if string exists, reset zero flag and
;                   exit, else, create the string and set the zero flag
;           else if A == 1, force overwrite of string
;  output:  new string created in TIOS
;  affects: TIOS string variable
;           assume most everything
;  total: 65b
;  tested: yes
;===============================================================================
StringCreate:
    push de                 ;pointer to string data
    push af                 ;save A, option indicator
    dec hl                  ;copy anything before string
                            ; for type byte
    rst 20h                 ;call _Mov10toOP1
    rst 10h                 ;call _FindSym to see if
                            ; variable exists
    jp nc,StringCreate_present
    pop af                  ;get this off the stack
    jp StringCreate_overwrite
StringCreate_forceoverwrite:
    call _delvar            ;delete variable if it exists
                            ;all necessary info still
                            ; preserved
StringCreate_overwrite:
    pop hl                  ;pointer to string data
    push hl         
    call _strlen            ;get length of string -> BC
    pop de                  ;pointer to string data
    ld h,b
    ld l,c
    push hl                 ;length of string
    push de                 ;pointer to string data
    call _createstrng       ;$472f  create string
    call _ex_ahl_bde        ;$45f3  ABS bde &  ahl swapped
    call _ahl_plus_2_pg3    ;$4c3f  increase ABS ahl by two
    call _set_abs_dest_addr ;$5285  set that as
                            ; destination for block copy
    xor a                   ;AKA ld a,0
    pop hl                  ;pointer to string data
                            ;address of string is in
                            ; relation to 16 bit
                            ; and ram page
    call _set_abs_src_addr  ;$4647  set that as source
                            ; for block copy
    xor a                   ;AKA ld a,0 -it's on already
                            ; swapped in page (0)
    pop hl                  ;length of string
    call _set_mm_num_bytes  ;$464f  set # of bytes to copy
                            ; in block copy
    call _mm_ldir           ;$52ed  ABS block copy
                            ;we jump instead of calling
                            ; and returning
                            ;this way we just use
                            ; _MM_Ldir's ret as ours
                            ;saves 1 byte
    ;set zero flag and return
    call SetZeroFlag
    ret

StringCreate_present:    ;string is present, check for default mode
    pop af          ;get mode indicator, A
    cp 1            ; (A =! 1) == default mode, no forced overwrite
    jp z,StringCreate_forceoverwrite

    pop de          ;get this off the stack

    ;reset the zero flag
    call ResetZeroFlag

    ;return
    ret

