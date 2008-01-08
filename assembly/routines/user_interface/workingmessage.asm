

;==============================================================================
; workingmessage -- clears the screen and displays a "working..." message
;  input: none
;  output: message is printed to screen
;  affects: assume everything
;  total: b
;  tested: no
;==============================================================================
workingmessage:
    call _clrScrn               ;clear the screen

        ld a,1                  ;display message text
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld hl,working_text
    call _puts

    ret

