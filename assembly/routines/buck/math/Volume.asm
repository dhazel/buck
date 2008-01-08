
    
;===============================================================================
; Volume -- calculates the scribner volume of a given log
;  input:   D   = diameter of log (in inches)
;           SP(0) = Li[s]   (pointer to length of log)
;  output:  DE  = volume of log
;           OP1 = volume of log
;           SP(1) = Li[s] (pointer to length of log)
;  affects: assume everything
;           SP(0) <- B,((the current length) - (trim))
;           BC  <- returning address
;           HL  <- second byte of temp
;           'temp' variable
;           * does not affect IX
;  total: 415b/956t (excluding func calls, including ret)
;  tested: yes
;   NOTE: this routine was originally made to be jumped to, but has been
;       modified in order to be called. Some of the comments are misleading.
;===============================================================================
Volume:
    ;[d == diameter; sp(0) == Li[s]; b == s]
    
    ; run as though this was jumped to, store return pointer in temp
    ld e,b ;[s]
    pop bc ;[return pointer]
    ld hl,temp
    ld (hl),b
    inc hl
    ld (hl),c           ;[now temp holds the call return pointer]
    ld b,e ;[s]
                    ;#This is a function containing a programmed model of the Scribner log rule, 
                    ;#   board-foot log volume tables.  It outputs the Scribner log volume for an 
                    ;#   input log length and top diameter.
                    ;#
                    ;#    Annotation:     [v]=logvolume(L,TD)
                    ;#                   v = Scribner log volume
                    ;#                   L = log length
                    ;#                   TD = top diameter
                    ;
                    ;import sys
                    ;
    jp Volume_tablehop
                    ;volume_table_1 = [1.07,4.9,6.043,7.14,8.88,10.0,11.528,13.29,14.99,17.499,18.99,20.88,23.51,25.218,28.677,31.249,34.22,36.376,38.04,41.06,44.376,45.975] 
    ;[NOTE -- this is wierd but correct representation (decimal written as hex)]
    ;[NOTE -- I have divided each table element by 10 so the equation need not]
Volume_table_1: .db $ff,$fb,$10,$70,$00,$ff,$fb,$49,$00,$00,$ff,$fb,$60,$43,$00
                .db $ff,$fb,$71,$40,$00,$ff,$fb,$88,$80,$00,$00,$fc,$10,$00,$00
                .db $00,$fc,$11,$52,$80,$00,$fc,$13,$29,$00,$00,$fc,$14,$99,$00
                .db $00,$fc,$17,$49,$90,$00,$fc,$18,$99,$00,$00,$fc,$20,$88,$00
                .db $00,$fc,$23,$51,$00,$00,$fc,$25,$21,$80,$00,$fc,$28,$67,$70
                .db $00,$fc,$31,$24,$90,$00,$fc,$34,$22,$00,$00,$fc,$36,$37,$60
                .db $00,$fc,$38,$04,$00,$00,$fc,$41,$06,$00,$00,$fc,$44,$37,$60
                .db $00,$fc,$45,$97,$50
                    ;volume_table_2 = [1.160,1.400,1.501,2.084,3.126,3.749 , 1.249,1.608,1.854,2.410,3.542,4.167 , 1.57,1.8,2.2,2.9,3.815,4.499] 
Volume_table_2: .db $ff,$fb,$11,$60,$00,$ff,$fb,$14,$00,$00,$ff,$fb,$15,$01,$00
                .db $ff,$fb,$20,$84,$00,$ff,$fb,$31,$26,$00,$ff,$fb,$37,$49,$00
                .db $ff,$fb,$12,$49,$00,$ff,$fb,$16,$08,$00,$ff,$fb,$18,$54,$00
                .db $ff,$fb,$24,$10,$00,$ff,$fb,$35,$42,$00,$ff,$fb,$41,$67,$00
                .db $ff,$fb,$15,$70,$00,$ff,$fb,$18,$00,$00,$ff,$fb,$22,$43,$00
                .db $ff,$fb,$29,$00,$00,$ff,$fb,$38,$15,$00,$ff,$fb,$44,$99,$00
Volume_tablehop:
                    ;
                    ;def logvolume_2(L,TD):
    ;[below\/\/<--] ;    L = L - (0.8333)    #Account for 10 inch over cut
                    ;
    ld a,d ;[a <- top diameter]
    cp 5            ;    if TD < 5:
    jp nc,Volume_fiesle1
                    ;        L = 0  # makes v = 0 in the output
    jp ErrMinDiam   ;        print "Top diameter reached:", TD
                    ;        TD = 11 # handles out-of-bounds errors
                    ;        print "Error! Top diameter minimum limit of 5 inches."
Volume_fiesle1:            ;    elif TD >= 32:
    cp 32
    jp c,Volume_fiesle2
                    ;        print 'Error! %3.1f inch top diameter exceeds the current 32.0 inch program capability.\n' %TD 
    jp ErrMaxDiam   ;        L = 0 
                    ;        TD = 11
                    ;
Volume_fiesle2:
                 ;+++++\/\/
    ld h,d ;[POP LENGTH BACK AND PREPARE INDEXING]
    ld e,5 ;[tables (and also the indexing) are now expanded by a multiple of 5]
    ld c,b ;[save b]
    call Mult8Bit ;[hl=h*e][expected not to exceed 255]
    ld b,c
    ld c,l ;[c <- new index-adjusted top diameter]
    pop hl ;[hl == Li[s]][or... (hl) == L]
    ld a,(hl)
    dec a ;[L = L - (trim)][trim == 1 foot over-cut]
                 ;+++++/\/\
                 
    cp 41           ;    elif L > 40:
    jp c,Volume_fiesle3
                    ;        print "Log length reached:", L
    jp ErrMaxLgth   ;        L = 0 
                    ;        print 'Error! Maximum log length is 40 feet.'
Volume_fiesle3:     ;    elif L < 1:
    cp 1
    jp nc,Volume_fi6
                    ;        print "Log length reached:", L
    jp ErrMinLgth   ;        L = 0 
                    ;        print 'Error! Minimum log length is 1 foot.'
Volume_fi6:         ;
    ld e,a ;[e <- Length]
    ld a,c ;[a <- diameter][ _op2set0 (below) wipes out A]
    ld d,b ;[d <- overall index state (special variable 's')]
    ;[I don't like pushes here but I think they may be necessary]
    push hl ;[hl == Li[s] ]
    push de ;[d == s, e == L]
    cp 30           ;    if (TD >= 6) & (TD <= 11):
    jp c,Volume_esle6
    cp 60
    jp nc,Volume_esle6                
    sub 30          ;        TD = TD - 6 #normalize TD with 6 for array indexing
    ld c,a ;[c <- diameter]
    ld a,e ;[a <- Length]
    cp 16           ;        if L < 16:
    jp nc,Volume_fiesle4
    call _setXXop1  ;            v = 10 * round((L * volume_table_2[TD]) / 10.0)
    call _op2set0
    ld hl,Volume_table_2
    ld de,_op2Location+1
    ld b,0
    add hl,bc ;[Volume_table_2 + offset]
    jp Volume_formula   
Volume_fiesle4:
    cp 31           ;        elif L < 31:
    jp nc,Volume_fiesle5
    call _setXXop1  ;            v = 10 * round((L * volume_table_2[TD + 6]) / 10.0)
    call _op2set0
    ld hl,Volume_table_2+30
    ld de,_op2Location+1
    ld b,0
    add hl,bc ;[Volume_table_2 + offset]
    jp Volume_formula
Volume_fiesle5:
    cp 41           ;        elif L < 41:
    jp nc,Volume_esle7
    call _setXXop1  ;            v = 10 * round((L * volume_table_2[TD + 12]) / 10.0)
    call _op2set0
    ld hl,Volume_table_2+60
    ld de,_op2Location+1
    ld b,0
    add hl,bc ;[Volume_table_2 + offset]
    jp Volume_formula
Volume_esle7:       ;       else:
    call _op1set0   ;            v = 0
    jp Volume_fi7
Volume_esle6:
    cp 25           ;        if TD == 5:
    ld a,e ;[a == Length][this should not affect the flags!]
    jp nz,Volume_esle8
    call _setXXop1  ;            v = 10 * round((L * volume_table_1[0]) / 10.0) 
    call _op2set0
    ld hl,Volume_table_1
    ld de,_op2Location+1
    jp Volume_formula
Volume_esle8:       ;        else:
    call _setXXop1  ;            v = 10 * round((L * volume_table_1[TD - 11]) / 10.0) 
    call _op2set0
    ld hl,Volume_table_1-55
    ld de,_op2Location+1
    ld b,0
    add hl,bc ;[Volume_table_1 + offset]
Volume_formula:;[reusable code in the volume calculation]
    ld bc,5
    ldir
    call _FPMULT
    ld d,0
    call _ROUND
    ld hl,_op1Location+1
    inc (hl) ;[op1 = op1 * 10]
Volume_fi7:         ;
    call ConvOP1
Volume_endVol:      ;    return v
                    ;
    ;[sp(0) == (the status iterator 's'),((the current length) - (trim))]
    ;[sp(1) == Li[s]] [pointer into the length iterator array]
    ;[de == op1 == volume of log]
    
    ; recall return pointer from temp and push it before calling ret
    ld hl,temp
    ld b,(hl)
    inc hl
    ld c,(hl)
    push bc
    ret             ;return

