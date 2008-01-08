
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
    ld a,(ErrMinDiam - 2)           ;if no error then skip displaying it
    cp 0
    jp z,PrintErrors_overMinDiam
    ld hl,errMinDiam_text
    call _puts
    ld hl,ErrMinDiam-2
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,ErrMinDiam-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overMinDiam:
    
    ld a,(ErrMaxDiam - 2)
    cp 0
    jp z,PrintErrors_overErrMaxDiam
    ld hl,errMaxDiam_text
    call _puts
    ld hl,ErrMaxDiam-2
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,ErrMaxDiam-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMaxDiam:

    ld a,(ErrMinLgth - 2)
    cp 0
    jp z,PrintErrors_overErrMinLgth
    ld hl,errMinLgth_text
    call _puts
    ld hl,ErrMinLgth-2
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,ErrMinLgth-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMinLgth:

    ld a,(ErrMaxLgth - 2)
    cp 0
    jp z,PrintErrors_overErrMaxLgth
    ld hl,errMaxLgth_text
    call _puts
    ld hl,ErrMaxLgth-2
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    ld hl,ErrMaxLgth-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrMaxLgth:

    ld a,(ErrReverseTaper - 1)
    cp 0
    jp z,PrintErrors_overErrReverseTaper
    ld hl,errReverseTaper_text
    call _puts
    ld hl,ErrReverseTaper-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
    call _getkey
    call _newline
PrintErrors_overErrReverseTaper:

    ld a,(ErrIntpolatOverrun - 1)
    cp 0
    jp z,PrintErrors_overErrIntpolatOverrun
    ld hl,errIntpolatOverrun_text
    call _puts
    ld hl,ErrIntpolatOverrun-1
    ld l,(hl)
    xor a               ;A = 0
    ld h,0              ;H = 0
    call _dispAHL
PrintErrors_overErrIntpolatOverrun:
    
    ret
    

