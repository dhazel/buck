
    
;============================================================
; ArryAccessW_ne -- returns the address of the requested 
;                   element of a dataword array
;                   (non error-check version)
;  input: HL = pointer to the array
;         B  = indicy number (array offset)
;  output: HL = pointer to array element
;  affects: A = B
;  total: 9b/42t (including ret)
;  tested: yes
;============================================================
ArryAccessW_ne:
    ld a,b      ;copy indicy number into A
    sla a       ;multiply indicy number by two
    add a,l     ;simulated 16-bit addition (for speed)
    ld l,a
    adc a,h
    sub l
    ld h,a
    ret
    
