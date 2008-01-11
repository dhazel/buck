
#ifdef DEBUG

;============================================================
; TestPrints -- displays all output arrays generated by
;               the bucking algorithm
;  input:   p1, p2, Lf, Lf2, v1, v2, td1, td2  
;  output:  output printed to screen
;  affects: assume everything
;  total: 254b/1036t (excluding func calls, including ret)
;  tested: yes
;============================================================
TestPrints:
    call _newline
    call _getkey
    jp TestPrints_over_testprints_data
price_array_text:  .db "Prices:",0
length_array_text: .db "Lengths:",0
volume_array_text: .db "Volumes:",0
diam_array_text:   .db "Diams:",0
separator_text:    .db "------",0
TestPrints_over_testprints_data:

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,user_l
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,user_p
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,user_v
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,separator_text
    call _puts
    call _newline

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,Lf
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,p1
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,v1
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,diam_array_text
    call _puts
    call _newline
    ld ix,td1
    ld b,5
    call PrintArray
    call _newline
    call _getkey
 
    ld hl,separator_text
    call _puts
    call _newline

    ld hl,length_array_text
    call _puts
    call _newline
    ld ix,Lf2
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ld hl,price_array_text
    call _puts
    call _newline
    ld ix,p2
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,volume_array_text
    call _puts
    call _newline
    ld ix,v2
    ld b,5
    call PrintArrayW
    call _newline
    call _getkey
    
    ld hl,diam_array_text
    call _puts
    call _newline
    ld ix,td2
    ld b,5
    call PrintArray
    call _newline
    call _getkey
    
    ret



                 


#endif
