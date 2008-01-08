

;============================================================
; Mult8Bit -- performs the operation HL = H * E
;  input: H = multiplicand
;         E  = multiplier
;  output: HL = product
;  affects: B  -> 0
;           DE -> destroyed
;  total: 13b/316t (minimum, including ret)
;  tested: yes
;============================================================
Mult8Bit:                        ; this routine performs the operation HL=H*E
  ld d,0                         ; clearing D and L
  ld l,d
  ld b,8                         ; we have 8 bits
Mult8BitLoop:
  add hl,hl                      ; advancing a bit
  jp nc,Mult8BitSkip             ; if zero, we skip the addition 
  add hl,de                      ; adding to the product if necessary
Mult8BitSkip:
  djnz Mult8BitLoop
  ret
  
