

;============================================================
; AboutBuck -- when called, prints information about the 
;               program and author to the screen
;  input: none
;  output: message printed to screen, program pause
;  affects: Assume all registers
;  total: tba (excluding called functions, including ret)
;  tested: yes
;============================================================
AboutBuck_text1: .db "Contact Information",0
AboutBuck_text2: .db "Author: David Hazel  Email:                    dhazel@gmail.comCompany: Tall Timber      Silviculture    Phone: 503-873-3477",0
AboutBuck_text3: .db "Program Information",0
AboutBuck_text4: .db "Calculates optimal    buck lengths using   Scribner log volumes and linear           interpolation.",0
AboutBuck:
    ;print pretty picture screen
    call BuckScreen
    
    call _runindicoff           ;turn run indicator off
    
    ;print onformation about the program
        ld a,0                  ;display about text3
    ld (_curCol),a
        ld a,0
    ld (_curRow),a
    ld hl,AboutBuck_text3
    call _puts
        ld a,0                  ;display about text4
    ld (_curCol),a
        ld a,2
    ld (_curRow),a
    ld hl,AboutBuck_text4
    call _puts
    
    call _getkey                ;pause for keypress
    
    ;print contact info etcetera
        ld a,0                  ;display about text1
    ld (_curCol),a
        ld a,0
    ld (_curRow),a
    ld hl,AboutBuck_text1
    call _puts
        ld a,0                  ;display about text2
    ld (_curCol),a
        ld a,2
    ld (_curRow),a
    ld hl,AboutBuck_text2
    call _puts
    
    call _getkey                ;pause for keypress
    call _runindicon            ;turn run indicator back on
    
    ret


;============================================================
; BuckScreen -- when called, prints a pretty picture to the 
;               screen introducing the program
;  input: none
;  output: message printed to screen
;  affects: Assume all registers
;  total: 345b/408t (excluding called functions, including ret)
;  tested: yes
;============================================================
BuckScreen:
    ;print pretty picture screen
    di          ;so we're not also counting the interrupt times
    call _clrScrn
    call _runindicoff

    ld bc,75    ;number of times the map is drawn (in effect, a pause)

BuckScreenloop:
        push bc
;-----------------------------------
    ld hl,tile_data
    call tile_gen
;-----------------------------------
        pop bc
    dec bc
    ld a,b
    or c
    jr nz,BuckScreenloop

    ld hl,0
    ld (_curRow),hl
    ld hl,BuckScreenheading_text1
    call _puts
        ld hl,1
    ld (_curRow),hl
    ld hl,BuckScreenheading_text2
    call _puts
        ld hl,4
    ld (_curRow),hl
    ld hl,BuckScreenheading_text3
    call _puts
;        ld hl,7
;    ld (_curRow),hl
        ld hl,0
    ld (_penCol),hl
        ld hl,58
    ld (_penRow),hl
    ld hl,BuckScreenauthor_tribute
    call _vputs
    call _getkey
    ei          ;so we're not also counting the interrupt times
    call _clrScrn
    call _runindicon

    
    ret
    
BuckScreenheading_text1:  .db "Tall Timber",0
BuckScreenheading_text2:  .db " Silviculture",0
BuckScreenheading_text3:  .db "Bucking Calculator",0
BuckScreenauthor_tribute: .db "by David Hazel",0
tile_data:
    .db 8,8,8,8,8,8,8,8,8,8,0,0,1,0,0,0
    .db 8,8,8,8,8,8,8,8,8,8,0,1,1,1,0,0
    .db 4,4,4,4,4,4,4,4,4,4,0,1,1,1,0,0
    .db 5,5,5,5,5,5,5,6,5,5,6,6,6,6,1,0
    .db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,1,0
    .db 4,4,4,4,4,4,7,7,7,7,7,7,7,7,1,1
    .db 0,0,0,0,0,1,1,1,1,1,0,0,3,0,0,0
    .db 0,0,0,0,0,0,0,2,0,0,0,0,3,0,0,0
tile0:
    .db %10000100
    .db %01000010
    .db %00100001
    .db %00010000
    .db %00001000
    .db %10000100
    .db %01000010
    .db %00100001
tile1:
    .db %00011000
    .db %00011000
    .db %10111101
    .db %00111100
    .db %01100110
    .db %01100110
    .db %11011011
    .db %11111111
tile2:
    .db %00111100
    .db %00111100
    .db %00111100
    .db %00111100
    .db %00111100
    .db %00111100
    .db %00111100
    .db %00111100
tile3:
    .db %11111111
    .db %11111111
    .db %11111111
    .db %11111111
    .db %11111111
    .db %11111111
    .db %11111111
    .db %11111111
tile4:
    .db %00000000
    .db %11111111
    .db %00100001
    .db %00010000
    .db %00001000
    .db %10000100
    .db %01000010
    .db %00100001
tile5:
    .db %10000100
    .db %01000010
    .db %00100001
    .db %00010000
    .db %00001000
    .db %10000100
    .db %11111111
    .db %00000000    
tile6:
    .db %00011000
    .db %00011000
    .db %10111101
    .db %00111100
    .db %01100110
    .db %01100110
    .db %11111111
    .db %00000000
tile7:
    .db %00000000
    .db %11111111
    .db %10111101
    .db %00111100
    .db %01100110
    .db %01100110
    .db %11011011
    .db %11111111
tile8:
    .db %00000000
    .db %00000000
    .db %00000000
    .db %00000000
    .db %00000000
    .db %00000000
    .db %00000000
    .db %00000000
    
;end BuckScreen


;==================================
; tile_gen -- draws a 16x8 tile map
;
;==================================
tile_gen:
    ld ix,$fc00     ;where to draw it to
    ld b,8          ;8 rows of tiles
tile_gen_loop_row:
        push bc     ;save our loop counter
tile_gen_columns:
    ld b,16         ;16 columns of tiles
tile_gen_loop_columns:
        push hl     ;save where we are in data
    ld l,(hl)       ;tile data
    ld h,0          ;clear upper byte of address
    add hl,hl       ;*2
    add hl,hl       ;*2
    add hl,hl       ;*2 = 2*2*2 = 8
                ;each tile is 8 bytes long
    ld de,tile0     ;address of first tile
    add hl,de       ;get offset in tile image data

tile_gen_draw_tile:
    ld de,$10       ;$10 bytes to get to next row
    ld c,b          ;save our column counter
    ld b,8          ;need to copy 8 bytes
                ; from tile image
        push ix     ;save where we are in video mem
tile_gen_draw_tile_loop:
    ld a,(hl)       ;get byte from tile image
    ld (ix),a       ;draw it onto video memory
    add ix,de       ;increase row in the video
                ; memory we're working with
    inc hl          ;increase the address in
                ; tile data
    djnz tile_gen_draw_tile_loop
        pop ix      ;get back where we were in
                ; video memory
    ld b,c          ;get back our column counter
        pop hl      ;get back where we were in
                ; the tile data
    inc hl          ;inc tile data - next tile
    inc ix          ;inc video mem - next col
    djnz tile_gen_loop_columns
    ld de,$10*7     ;need to move down now
    add ix,de
        pop bc      ;get back our row counter
    djnz tile_gen_loop_row
    ret
