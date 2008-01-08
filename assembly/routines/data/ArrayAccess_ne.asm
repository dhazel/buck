

;============================================================
; ArrayAccess_ne -- returns the address of a requested 
;                   element (non error-check version)
;  input: HL = pointer to the array
;         B  = indicy number (array offset)
;  output: HL = pointer to array element
;  affects: A = B
;  total: 7b/34t (including ret)
;  tested: yes
;============================================================
ArrayAccess_ne:
    ld a,b      ;copy indicy number into A
    add a,l     ;simulated 16-bit addition (for speed)
    ld l,a
    adc a,h
    sub l
    ld h,a
    ret
    
