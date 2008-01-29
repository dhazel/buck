
;============================================================
; PrintErrors -- prints all logged errors to the screen
;  input: -none- requires the error handlers
;  output: print to screen
;  affects: most everything
;  total: 352b/1145t (including ret, excluding func. calls)
;  tested: yes
;============================================================
PrintErrors_head_text: .db "Errors Encountered",0
PrintErrors_head_text2: .db "  (press any key)",0
errMinDiam_text: .db "MinDiam:",0
errMaxDiam_text: .db "MaxDiam:",0
errMinLgth_text: .db "MinLgth:",0
errMaxLgth_text: .db "MaxLgth:",0
errReverseTaper_text: .db "ReverseTaper:",0
errIntpolatOverrun_text: .db "IntpolatOverrun:",0

PrintErrors:
    call clearwindow
    call clearmenu
    call _homeup

    ;print header
    ld hl,PrintErrors_head_text
    call _puts
    call _newline
    ld hl,PrintErrors_head_text2
    call _puts
    call _newline
    call _newline
    call _getkey

    ;print errors
    ld a,(err_MinDiam_occured)           ;if no error then skip displaying it
    cp 0
    jp z,PrintErrors_overMinDiam
    ld hl,errMinDiam_text
    call _puts
    ld hl,err_MinDiam_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,err_MinDiam_bound
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overMinDiam:
    
    ld a,(err_MaxDiam_occured)
    cp 0
    jp z,PrintErrors_overErrMaxDiam
    ld hl,errMaxDiam_text
    call _puts
    ld hl,err_MaxDiam_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,err_MaxDiam_bound
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMaxDiam:

    ld a,(err_MinLgth_occured)
    cp 0
    jp z,PrintErrors_overErrMinLgth
    ld hl,errMinLgth_text
    call _puts
    ld hl,err_MinLgth_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,err_MinLgth_bound
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMinLgth:

    ld a,(err_MaxLgth_occured)
    cp 0
    jp z,PrintErrors_overErrMaxLgth
    ld hl,errMaxLgth_text
    call _puts
    ld hl,err_MaxLgth_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,err_MaxLgth_bound
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMaxLgth:

    ld a,(err_ReverseTaper_occured)
    cp 0
    jp z,PrintErrors_overErrReverseTaper
    ld hl,errReverseTaper_text
    call _puts
    ld hl,err_ReverseTaper_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrReverseTaper:

    ld a,(err_IntpolatOverrun_occured)
    cp 0
    jp z,PrintErrors_overErrIntpolatOverrun
    ld hl,errIntpolatOverrun_text
    call _puts
    ld hl,err_IntpolatOverrun_occured
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
PrintErrors_overErrIntpolatOverrun:
    
    ret
    

