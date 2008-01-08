

;* The Buck Algorithm
;*******************************************************************************



;============================================================
; Buck -- This is the Buck algorithm. It uses mill length and
;           price information along with tree description 
;           data to determine the optimal buck lengths for 
;           the input tree.
;  input: TODO
;  output: TODO
;  affects: assume everything
;  total: 566b (including ret)
;  tested: yes -- heavily
;============================================================
    jp Buck         ; just in case!
Buck_text: .db "Please Wait          ",0
Buck:
    ;get firstchoice and secondchoice column names and mill numbers
    ld hl,mill_name
    ld de,firstchoice_result_name
    call _strcpy
    ld hl,mill_name
    ld de,secondchoice_result_name
    call _strcpy

    ld a,(currentmill_number)
    ld hl,firstchoice_mill_number
    ld (hl),a
    ld hl,secondchoice_mill_number
    ld (hl),a
    
;\/\/\/TESTING
    ;place test instructions here
;/\/\/\/\/\/\/


;buck algorithm=================================================================
    call _runindicoff           ;[turn run indicator off]
    ;di               ;[disable interrupts] [disables calculator automatic halt]
                      ;[this is a problem if the batteries are low enough that ]
                      ;[    the screen goes dim. (the darkening keys are       ]
                      ;[    disabled)                                          ]
    call _clrScrn               ;[display run message]
        ld a,5
    ld (_curCol),a
        ld a,3
    ld (_curRow),a
    ld hl,Buck_text
    call _puts    
    
    ld a,(length)               ;[check maximum length]
    ld hl,max_length
    cp (hl) ;[maximum tree length beyond which calculator processes for too long etcetera]
    call nc,ErrTooLong
                    ;
    ld hl,LCV       ;    for entry in LCV:               #find minimum length
Buck_for0:      
    ld a,(min_length);       if min_length > entry:
    cp (hl)
    jp c,Buck_fi0
    ld a,(hl)       ;           min_length = entry
    ld (min_length),a
Buck_fi0:
    ld a,255 
    cp (hl)
    inc hl ;[<- shouldn't affect flags]
    jp nz,Buck_for0 ;[255 terminated vector -- loop until the end]
                    ;
                    
                    
                    
    ld b,0          ;    s=0
Buck_main:          ;    while s >= 0:
                    ;
    ld hl,it        ;        if it[s] == 255:              #eg "top" of tree
    call ArrayAccess ;                # (there will never be 255 LCV elements)
    ld a,(hl)
    cp 255
    jp nz,Buck_esle1
    ld (hl),0       ;            it[s] = 0
    push hl
    pop ix ;[(IX) <- it[s]]
    ld hl,Li        ;            for entry in LCV:
    call ArrayAccess
    ld a,(hl)
    ld (Li[s]_temp),a
    push hl
    ld hl,LCV       
Buck_for1:
    ld a,(Li[s]_temp);               if (entry + 0.8333) <= Li[s]:
    cp (hl)
    jp c,Buck_fi2
    ld a,(hl)        ;                    Li[s] = entry + 0.8333
    ld (Li[s]_temp),a
    inc (ix)         ;                    it[s] = it[s] + 1
    jp Buck_rof1     ;                    break
Buck_fi2:
    inc (ix)        ;                it[s] = it[s] + 1
    ld a,255        ;            if entry == 255:
    cp (hl)         ;                print "\n Too short!\n"
    call z,ErrTooShort ;             break
    inc hl 
    jp Buck_for1 ;[beware the danger of this statement!]
Buck_rof1:
    dec (ix)        ;            it[s] = it[s] - 1
    ld a,(Li[s]_temp)
    pop hl
    ld (hl),a ;[Li[s] = entry + trim ^^ from above]
    jp Buck_fi1     ;        else:                       #middle of tree
Buck_esle1:
    inc (hl)        ;            it[s] = it[s] + 1
    push hl  ;[it[s]]
    ld e,(hl);[E <- it[s]]
    push de

    ld hl,Li        
    call ArrayAccess
    push hl ;[Li[s]]
    ld c,b
    ld b,e  ;[B <- it[s]]
    ld hl,LCV       
    call ArrayAccess_ne ;[(HL) <- LCV[it[s]]]
    ld b,c  ;[maintain B]

    pop ix          ;            Li[s] = 0
    ld (ix),0
    ld (ix+1),0     ;            Li[s+1] = 0
    ld d,h ;[save HL for later]
    ld e,l
    ld hl,Li        ;            while (L - sum(Li)) < (LCV[it[s]] + 0.8333):
    call SumBytArray
    ld h,d
    ld l,e ;[(HL) <- LCV[it[s]]]
    ld e,a ;[E <- sum(Li)]
    ld a,(length)
    sub e  ;[A <- (L - sum(Li))]
    pop de ;[E <- it[s]]
    ld c,e ;[C <- it[s]]
Buck_while0:
    ld d,a
    ld a,255        ;                if (LCV[it[s]] == 255):
    cp (hl)
    jp z,Buck_check255;                   break
    inc c           ;                it[s] = it[s] + 1
    ld a,d
    cp (hl)
    inc hl
    jp c,Buck_while0
    dec hl
    dec c
    jp Buck_check255end
Buck_check255: 
    pop hl      ;[(HL) <- it[s]]
    ld (hl),c   ;[it[s] <- updated it[s]]
                    ;
    ld a,b          ;            if (LCV[it[s]] == 255) & (s == 0):
    cp 0
    jp z,Buck_end   ;                break              # END! QUIT! VAMOS! NOW!
    ;unnecessary    ;            if (LCV[it[s]] == 255):
                    ;            #clear all previous log lengths from the top of the tree
    ld (ix),0       ;                Li[s] = 0   
    ld a,b          ;                if (s+1) < len(Li):
    inc a
    cp 6
    jp nc,Buck_fi11
    ld (ix + 1),0   ;                    Li[s+1] = 0
Buck_fi11:
    ld hl,p         ;                p[s] = 0
    call ArryAccessW
    ld (hl),0
    inc hl
    ld (hl),0
    ld hl,v         ;                v[s] = 0
    call ArryAccessW
    ld (hl),0
    inc hl
    ld (hl),0
    ld hl,td        ;                td[s] = 0
    call ArrayAccess
    ld (hl),0
    ld hl,it        ;                it[s] = 255
    call ArrayAccess
    ld (hl),255 ;[there will never be 255 LCV elements]
    dec b           ;                s = s - 1
    jp Buck_main         ;                continue
Buck_check255end: 
                    ;
    ld a,(hl)       ;            Li[s] = LCV[it[s]] + 0.8333
    ld (ix),a
    push ix ;[load hl properly for consistancy with below (Li[s])]
    pop hl 
    pop ix      ;[(IX) <- it[s]]
    ld (ix),c   ;[it[s] <- updated it[s]]
Buck_fi1:                ;
   ;[(IX) == it[s]]
                    ;
                    ;#        print 'log loop %i\n' %s
                    ;#        print 'Li[s] = %0.4f\n' %Li[s]
                    ;
                    ;
    
    
    push hl ;[Li[s]] ;[NOTE -- don't forget to pop these out later!]
    push bc ;[b == s]
    ld a,b
    ld (status_iterator),a ;[useful for debugging, used by VarDump only]
    ld hl,Li         ;                                   #calculate length price
    call SumBytArray ;       dia = interpolate.interpolate(sum(Li),log,log_dia)
        ;interpolate--------------------------------------------------
    call Interpolate
    ;[d = dia]
        ;/interpolate-------------------------------------------------

    ;[check to see if log criteria are satisfied]
    ld b,(ix)   ;[B <- it[s]]
    call CriteriaPassFail
    jp nc,Buck_overskip
Buck_skip:
    pop bc  ;[load B properly]
    pop hl  ;[get this off the stack!]
    jp Buck_main
Buck_overskip:

                    ;        dia = int(dia)      #
    ld hl,td        ;        td[s] = dia
    pop bc ;[b == s]
    call ArrayAccess
    ld (hl),d
               
        ;volume-------------------------------------------------------
    ;[d == diameter; sp(0) == Li[s]; b == s]
    call Volume     ;        v[s] = logvolume_2.logvolume_2(Li[s],dia)
    ;[sp(0) == (the status iterator 's'),((the current length) - (trim))]
    ;[sp(1) == Li[s]] [pointer into the length iterator array]
    ;[de == op1 == volume of log]
        ;/volume------------------------------------------------------

    pop bc
    ld hl,v ;[v[s] = volume]
    call ArryAccessW
    ld (hl),d
    inc hl
    ld (hl),e
    push bc
    inc c
    
        ;price--------------------------------------------------------
    ;[c == length; op1 == volume]
    call Price2         ;        p[s] = buck1p.buck1p(Li[s],v[s],p16,p30,p36)
    ;[the LCV_placeholder is now updated]
    ;[de == (price * 10)]
    ;[B is not still s]
        ;/price-------------------------------------------------------
    
    pop bc  ;[b == s]
    ld hl,p ;[p[s] = price]
    call ArryAccessW
    ld (hl),d
    inc hl
    ld (hl),e
        
    ld hl,Li       ;        Li[s+1] = L - sum(Li)   #bump remaining length ahead
    call SumBytArray
    ld c,a ;[c == sum(Li)]
    ld a,(length)
    sub c ;[a == L - sum(Li)]
    pop hl;[hl == Li[s] ]                       [SP = 0]
    inc hl
    ld (hl),a ;[Li[s+1] == L - sum(Li)]
    push hl ;[for later below (hl == Li[s+1])]
    dec hl
    
    push bc ;[b == s]
    
    ld ix,p         ;        sum_p = sum(p)
    call SumWrdArray
    ld d,h
    ld e,l ;[de == sum_p]
    
    ld a,0 ;[if sum_p is zero, skip Buck_copyblock]
    cp d
    jp nz,Buck_copyblock_start
    cp e
    jp z,Buck_fi9
    
Buck_copyblock_start:
    ld hl,(sum_p1)  ;        if sum_p >= sum(p1):
    ld a,h
    cp d
    jp c,Buck_copyblock1
    jp nz,Buck_fiesle6
    ld a,e
    cp l
    jp c,Buck_fiesle6
Buck_copyblock1:
    ld (sum_p),de ;[de == sum_p]

    ;copy the firstchoice variables into the secondchoice variables
    ld hl,firstchoice_result_vars
    ld de,secondchoice_result_vars
    ld bc,firstchoice_result_vars - transient_result_vars
    ldir ;[very cool instruction!!]

    ;copy the current transient results variables into the firstchoice variables
    ld hl,transient_result_vars
    ld de,firstchoice_result_vars
    ld bc,firstchoice_result_vars - transient_result_vars
    ldir 

    jp Buck_fi9          ;        elif sum_p >= sum(p2):
Buck_fiesle6:
    ;[de == sum_p]
    ld hl,(sum_p2)  ;[hl <- sum(p2)]
    ld a,h
    cp d
    jp c,Buck_copyblock2
    jp nz,Buck_fi9
    ld a,e
    cp l
    jp c,Buck_fi9
Buck_copyblock2:
    ld (sum_p),de ;[de == sum_p]

    ;copy the transient result variables into the secondchoice variables
    ld hl,transient_result_vars
    ld de,secondchoice_result_vars
    ld bc,firstchoice_result_vars - transient_result_vars
    ldir 

Buck_fi9:
    pop bc ;[b == s]
    pop hl ;[hl == Li[s+1]]
    
    ld a,0                      ;[print progress indicator if s == 0]
    cp b
    jp nz,Buck_over_progressindicator
    push bc
    push hl
    ld a,Lperiod
    call _putc
    pop hl
    pop bc
Buck_over_progressindicator:
    ; 
    ld a,(min_length);       if (Li[s+1] >= (min_length + 0.8333)) & (s < (lognum - 1)):
    dec a
    cp (hl)
    jp nc,Buck_fi10
    ld a,_lognum-2
    cp b
    jp c,Buck_fi10
    inc b           ;            s = s + 1
Buck_fi10:
    ;[main while loop return]
    jp Buck_main
Buck_end:
    ;[load the sum_v variables]
    ld b,5              ;[6 elements in these arrays]
    ld hl,p1            ;[determine the elements with value to sum]
    ld ix,v1            ;[sum the elements from v1]
    call SumWrdArray_rel
    ld (sum_v1),hl
    ld hl,p2            ;[determine the elements with value to sum]
    ld ix,v2            ;[sum the elements from v2]
    call SumWrdArray_rel
    ld (sum_v2),hl

    call _runindicon ;[turn run indicator back on]
    ei               ;[enable interrupts] [re-enables calculator automatic halt]
;/buck algorithm================================================================

    ret         ; return


