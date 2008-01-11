
    
;============================================================
; Interpolate -- given tree description data, this function
;               will interpolate the tree diameter at any
;               point along its length
;  input:   A   = point at which to find diameter (in feet)
;                   (butt is zero)
;           log = array describing log length segments
;                   (each element is the sum of the length to 
;                   that point) (ie: a 50' log might look
;                   like [0,10,20,45,50] )
;           log_dia = array of corresponding diameters 
;  output:  D   = diameter at A feet up the tree
;  affects: assume all registers A - F
;           * does not affect the OP registers
;           * does not affect the stack
;           * does not affect IX 
;  total: 92b/435t (excluding func calls, including ret)
;  tested: yes
;============================================================
Interpolate:
    ;[This assembly interpolation routine is not designed for negative inputs!!]
                    ;#Interpolation function  [yu]=interpolate(ux,x,y)
    ;[a holds ux]   ;#       x= vector of x values
                    ;#       y= vector of y values
                    ;#       ux= user entered x value
                    ;#       yu= the interpolated y value corresponding to the user x entry
                    ;
                    ;def interpolate(ux,x,y):
                    ;    j = 0 
                    ;    T = 0      
    ld c,_log_entries;    n = len(x) - 1
    ;[doesn't need ];    if ux == x[n]:                  #check endpoint of input vector
    ;[ implementing];       yu = y[n] 
    ;[NOTE -- d holds dia]
Interpolate_esle4:  ;    else:
    ld hl,log
Interpolate_while1: ;        while x[j] <= ux:           #run up to the vector point above and
    cp (hl)         ;            T = x[j]                #   nearest to the user value.                
    jp z,Interpolate_esle5 ;     j = j+1 
    jp c,Interpolate_ilehw1
    inc hl
    dec c ;[Will gracefully resume if array length is exceeded, but will output incorrect] 
    jp z,ErrIntpolatOverrun ;[data. The other algorithm checks *should* keep this from happening.]
    jp Interpolate_while1
Interpolate_ilehw1: 
    dec hl ;[NOTE -- wonky! but clearer this way. Losing one dec or inc will drop 6 clks]            
    ;cp (hl)        ;        if T != ux:
    ;jp z,Interpolate_esle5 ;[moved into loop above/\/\]
     
    push bc
                    ;            yu = ((y[j]-y[j-1])/(x[j]-x[j-1]))*ux-((y[j]-y[j-1])/(x[j]-x[j-1]))*x[j-1]+y[j-1] 
    ;[NOTE -- the original equation...]
    ;   [yu = (ux - x1)*(y2 - y1)/(x2 - x1) + y1]
    ;[NOTE -- the equation I am using...]
    ;[yu = (y1*(x2 - ux) + y2*(ux - x1))/(x2 - x1)]
    ;   [this avoids negative numbers; trees should _never_ have reverse taper]
    ;   [also fixes an integer tree representation (step function) problem 
    ;   [introduced by division location]
    ;[...]
    ;          [a == ux] 
    ld d,a ;   [d == ux]
    ld c,(hl) ;[c == x1]
    sub c
    ld e,a ;[e == (ux - x1)]
    inc hl
    ld a,(hl) ;[a == x2]
    sub d
    ld d,a ;[d == (x2 - ux)]

    ld a,_log_entries
    pop bc
    sub c
    ld b,a ;[b = j]
    ld hl,log_dia
    call ArrayAccess
    
    push de
    ld c,(hl) ;[c == y2]
    dec hl
    ld a,(hl) ;[a == y1]
    cp c 
    jp z,Interpolate_overTaperError
    jp c,ErrReverseTaper
Interpolate_overTaperError:
    ld l,e ;[l == (ux - x1)]
    ld e,a ;[e == y1]
    ld h,d ;[h == (x2 - ux)]
    ld a,l ;[a == (ux - x1)] [a is untouched by Mult8Bit]
    call Mult8Bit ;[hl == y1*(x2 - ux)] ;[hl may exceed 600 (well over 255)]
    ;push hl ;[using ld instructions instead]
    ld e,c ;[e == y2]
    ld c,h
    ld h,a ;[h == (ux - x1)]
    ld a,l
    call Mult8Bit ;[hl == y2*(ux - x1)] ;[hl may exceed 600]
    ;pop de ;[de == y1*(x2 - ux)]
    ld d,c
    ld e,a
    add hl,de ;[hl == y1*(x2 - ux) + y2*(ux - x1)]
    pop de ;[d == (x2 - ux); e == (ux - x1)]
    ;[(x2 - ux) + (ux - x1) = (x2 - x1)]
    ld a,d
    add a,e ;[a == (x2 - x1)]
    ld d,a ;[d == (x2 - x1)]
    call _divHLbyA ;[this does the same thing as Div8~16Bit]
    ;call Div8-16Bit ;[hl == (y1*(x2 - ux) + y2*(ux - x1))/(x2 - x1)]
    ld d,l
    
    jp Interpolate_endIntpolat;[jp Interpolate_fi5]   
Interpolate_esle5:  ;        else:
                    ;            yu=y[j-1] 
    ;[don't like repeating functionality, but here we must]
    ld a,_log_entries
    sub c
    ld b,a ;[b = j]
    ld hl,log_dia
    call ArrayAccess
    
    ld d,(hl) ;[d == y1]
Interpolate_fi5: 
Interpolate_fi4:    ;
Interpolate_endIntpolat: ;   return yu
        ;[d = dia]
    ret             ;return
        
