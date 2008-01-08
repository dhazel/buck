

;============================================================
; ArrayAccess -- returns the address of a requested element
;  input: HL = pointer to the array
;         B  = indicy number (array offset)
;  output: HL = pointer to array element
;  affects: A = B
;  total: 7b/34t (including ret)
;  tested: yes
;============================================================
ArrayAccess:
    ld a,b      ;copy indicy number into A
   ;- error checking code -;
    cp _lognum+1
    jp nc,Err_s_Overrun
   ;- - - - - - - - - - - -;
    add a,l     ;simulated 16-bit addition (for speed)
    ld l,a
    adc a,h
    sub l
    ld h,a
    ret
    
