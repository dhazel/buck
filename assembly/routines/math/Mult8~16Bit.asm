
    
;============================================================
; Mult8~16Bit -- performs the operation HL = DE * A
;  input: DE = multiplicand
;         A  = multiplier
;  output: HL = product
;  affects: B  -> 0
;           A  -> destroyed
;           DE -> destroyed
;  total: 17b/387t (minimum, including ret)
;  tested: yes
;============================================================
Mult8~16Bit:                     ; this routine performs the operation HL=DE*A
  ld hl,0                        ; HL is used to accumulate the result
  ld b,8                         ; the multiplier (A) is 8 bits wide
Mult8~16BitLoop:
  rrca                           ; putting the next bit into the carry
  jp nc,Mult8~16BitSkip          ; if zero, we skip the addition (jp is used for speed)
  add hl,de                      ; adding to the product if necessary
Mult8~16BitSkip:
  sla e                          ; calculating the next auxiliary product by shifting
  rl d                           ; DE one bit leftwards (refer to the shift instructions!)
  djnz Mult8~16BitLoop
  ret

