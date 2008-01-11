
    
;============================================================
; Div8to16Bit -- performs the operation HL = HL / D
;  input: HL = dividend
;         D  = divisor
;  output: HL = quotient
;  affects: B  -> 0
;           A  -> destroyed
;           DE -> destroyed
;  total: 14b/702t (minimum, including ret)
;  tested: yes
;   NOTE: This does the same thing that the _divHLbyA builtin does.
;           This method does have a limit and, depending on the
;               divisor, can not always handle a full 16 bit number
;               in HL (ie: try dividing 135 by 8).
;============================================================
Div8to16Bit:                      ; this routine performs the operation HL=HL/D
  xor a                          ; clearing the upper 8 bits of AHL
  ld b,16                        ; the length of the dividend (16 bits)
Div8to16Bit_Loop:
  add hl,hl                      ; advancing a bit
  rla
  cp d                ; checking if the divisor divides the digits chosen (in A)
  jp c,Div8to16Bit_NextBit        ; if not, advancing without subtraction
  sub d                          ; subtracting the divisor
  inc l                          ; and setting the next digit of the quotient
Div8to16Bit_NextBit:
  djnz Div8to16Bit_Loop
  ret          

