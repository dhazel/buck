

;==============================================================================
; bigmessage -- clears the screen and prints a large message with two choices
;  input: IX = array of pointers to each text string
;               (ie: IX(0)==message IX(1)==option1 IX(2)==option2)
;  output: message is printed with options
;  affects: assume everything
;  total: 68b (including ret)
;  tested: yes
;   NOTE: should be followed by a getkey to wait for user choice input
;==============================================================================
bigmessage: ;prints a message with two choices to the screen
    call clearwindow
    call clearmenu

        ld a,1                  ;display message text
    ld (_curCol),a
        ld a,1
    ld (_curRow),a
    ld l,(ix+0)
    ld h,(ix+1)
    call _puts

    set textinverse,(iy+textflags)  ;white on black
    
        ld a,23                 ;display option1
    ld (_penCol),a
        ld a,57
    ld (_penRow),a
    ld l,(ix+2)
    ld h,(ix+3)
    call _vputs

        ld a,80                 ;display option2
    ld (_penCol),a
        ld a,57
    ld (_penRow),a
    ld l,(ix+4)
    ld h,(ix+5)
    call _vputs

    res textinverse,(iy+textflags)  ;default black on white

    ret ; return

