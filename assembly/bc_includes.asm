
;* BUCK INCLUDES
;*****************************************************
                    
                                                            
;#include "ti86asm.inc"

#define carryFlag           0
#define addorsubFlag        1
#define parityoverflowFlag  2
#define halfcarryFlag       4
#define zeroFlag            6
#define signFlag            7
                                        
#define _op1Location $C089
#define _op2Location $C094
#define _op3Location $C09F
#define _op4Location $C0AA

_asm_exec_ram       equ     0D748h  ; start address for all ASM programs
_asapvar            equ     0D6FCh  ; name of the current asm prog
_exec_assembly      equ     5730h   ; exec assembly prog op1
_exec_basic         equ     4C47h	; basic program in op1
_ex_ahl_bde         equ     45F3h   ; exchange ahl and bde
_inc_ptr_ade        equ     45EFh   ; ade = ade + 1
_dec_ptr_ade        equ     46BFh	; ade = ade - 1
_inc_ptr_ahl        equ     4637h	; ahl = ahl + 1
_dec_ptr_ahl        equ     463Bh	; ahl = ahl - 1
_inc_ptr_bde        equ     463Fh	; bde = bde + 1
_dec_ptr_bde        equ     4643h	; bde = bde - 1
_getb_ahl           equ     46C3h	; a = (ABS ahl), hl = asic address
_writeb_inc_ahl     equ     5567h	; c -> (ABS ahl), ahl = ahl + 1
_get_word_ahl       equ     521Dh	; ld de,(ahl)  ahl = ahl + 2
_set_word_ahl       equ     5221h	; ld (ahl),de  ahl = ahl + 2
_abs_mov10toop1	    equ     5235h	; ahl -> (_abs_src_addr) mov 10b (_abs_src_addr) -> OP1
_abs_movfrop1_set_d equ     5241h	; ahl -> (_abs_dest_addr) mov 10b OP1 -> (_abs_dest_addr)
_set_abs_dest_addr  equ     5285h   ; ahl -> (_abs_dest_addr)
_set_abs_src_addr   equ     4647h   ; ahl -> (_abs_src_addr)
_set_mm_num_bytes   equ     464Fh   ; ahl -> (_mm_num_bytes)
_mm_ldir            equ     52EDh   ; 24bit ldir
_ahl_plus_2_pg3     equ     4C3Fh   ; increase ABS ahl by two
_createstrng        equ     472Fh   ; create new string variable
_creatermat_temp    equ     471Bh
_creatermat         equ     471Fh	; create real matrix op1, HL = row,col
_delvar             equ     475Fh   ; delete var
_errConversion      equ     4181h   ; error 24 CONVERSION
_jforcecmdnochar    equ     409Ch   ; force out of program
_ld_hl_bz           equ     437Bh   ; B zeros to (hl)
_strcpy             equ     495Bh   ; hl->source, de->destination
_strlen             equ     4957h   ; bc = length of string (hl)
_divHLbyA           equ     4048h   ; hl = hl/a

_cpop1op2           equ     41FBh	; cp op1,op2
_op1set1            equ     430Fh	; op1 = floating point 1
_op2set1            equ     432Fh   ; op2 = floating point 1
_op4set1            equ     42E7h	; op4 = floating point 1
_MINUS1             equ     5470h   ; op1 = op1 - 1
_FPSUB              equ     5474h   ; op1 = op1 - op2
_FPADD              equ     5478h   ; op1 = op1 + op2
_TIMESPT5           equ     5484h   ; op1 = .5 x op1
_FPSQUARE           equ     5488h   ; op1 = op1^2
_FPMULT             equ     548Ch   ; op1 = op1 x op2
_FPRECIP            equ     54A4h   ; op1 = 1/op1
_FPDIV              equ     54A8h   ; op1 = op1/op2
_op4set0            equ     4353h   ; op4 = floating point 0
_op3set0            equ     4357h   ; op3 = floating point 0
_op2set0            equ     435Bh   ; op2 = floating point 0
_op1set0            equ     435Fh   ; op1 = floating point 0
_mov10b             equ     427Bh   ; move 10 bytes at (hl) to (de)
_mov11b             equ     4277h   ; move 11 bytes at (hl) to (de)
_mov10toop1         equ     42D7h   ; move 10 bytes at (hl) to op1
_movtoop1           equ     4273h   ; move 11 bytes at (hl) to op1
_mov10toop2         equ     42DFh   ; move 10 bytes at (hl) to op2
_movtoop2           equ     4237h   ; move 11 bytes at (hl) to op2
_setXXop1           equ     4613h   ; convert hex # in A to flt point in op1
_setXXop2           equ     4617h   ; convert hex # in A to flt point in op2
_setXXXXop2         equ     461Bh   ; convert hex # in HL to flt point in op2
_ex_op1_op2         equ     448Fh   ; swap op1,op2
_ex_op1_op4         equ     448Bh   ; swap op1,op4
_ex_op2_op4         equ     447Fh   ; swap op2,op4
_convop1            equ     5577h   ; convert flt point in op1 to hex # in ade (max 9999) (destroys OP1)
_ROUND              equ     54C0h   ; round op1; D holds decimal place to round to

_mov5b              equ     4297h   ; move 5 bytes at (hl) to (de)
_mov6b              equ     4293h   ; move 6 bytes at (hl) to (de)
_clrScrn            equ     4A82h   ; clear LCD screen and _textShadow
_clrWindow          equ     4A86h   ; clear between _winTop and _winBtm
_homeup             equ     4A95h   ; cursor to top left of home screen
_dispAHL            equ     4A33h   ; disp AHL as decimal
_dispOP1            equ     515Bh   ; display op1 as result
_vputspace          equ     5643h	; a = ' '  _vputmap
_getkey             equ     55AAh   ; keypress -> A; modifies DE and HL
                                    ;   (breaks altogether if IY is modified)
_vputmap            equ     4AA1h   ; display variable width character (A=char)
_vputs              equ     4AA5h   ; display a string of variable width characters
_vputsn             equ     4AA9h   ; display B characters of string at (HL)
_putmap             equ     4A27h   ; display a character (A=char)
_puts               equ     4A37h   ; display a zero-terminated string (HL=ptr)
_putc               equ     4A2Bh   ; display a character and advance cursor
_putps              equ     4A3Bh   ; display a string with leading length byte
_newline            equ     4A5Fh   ; move cursor to next line
_put_colon          equ     4040h   ; disp ":"
_dispDone           equ     515Fh   ; print 'Done' right justified
_curRow             equ     0C00Fh  ; cursor row
_curCol             equ     0C010h  ; cursor column
_penCol             equ     0C37Ch  ; pen column
_penRow             equ     0C37Dh  ; pen row
_winTop             equ     0D13Dh  ; first homescreen row
_winBtm             equ     0D13Eh  ; last homescreen row
_runindicon         equ     4AADh   ; turn on run indicator
_runindicoff        equ     4AB1h   ; turn off run indicator
_cursoron           equ     4994h   ; turn on blinking cursor
_cursoroff          equ     498Ch   ; turn off blinking cursor
_scrollUp           equ     4A6Bh   ; scroll screen up
_scrollDown         equ     4A7Ah   ; scroll screen down


textflags           equ     $05     ; TI-OS text flags offset 
textinverse         EQU     3       ; TI-OS text-inverse flag offset
shiftflags          equ     $12     ; TI-OS shift flags offset
shiftLwrAlph        equ     5
shiftAlpha          equ     4
shiftALock          equ     6
shift2nd            equ     3
 
Lspace      equ     020h
Ldollar     equ     024h
Lbar        equ     07Ch
LcapB       equ     042h
LcapT       equ     054h
Lperiod     equ     02Eh
Lquote      equ     022h
Lapostrophe equ     027h
LsqUp       equ     006h
LsqDown     equ     007h
LupArrow    equ     01Eh
LdownArrow  equ     01Fh
Lstore      equ     01Ch
LblockArrow equ     0D7h
Lblock      equ     0D0h
L0          equ     030h
L1          equ     031h
L2          equ     032h
L3          equ     033h
L4          equ     034h
L5          equ     035h
L6          equ     036h
L7          equ     037h
L8          equ     038h
L9          equ     039h
LcapA       equ     041h
LcapB       equ     042h
LcapC       equ     043h
LcapD       equ     044h
LcapE       equ     045h
LcapF       equ     046h
LcapG       equ     047h
LcapH       equ     048h
LcapI       equ     049h
LcapJ       equ     04Ah
LcapK       equ     04Bh
LcapL       equ     04Ch
LcapM       equ     04Dh
LcapN       equ     04Eh
LcapO       equ     04Fh
LcapP       equ     050h
LcapQ       equ     051h
LcapR       equ     052h
LcapS       equ     053h
LcapT       equ     054h
LcapU       equ     055h
LcapV       equ     056h
LcapW       equ     057h
LcapX       equ     058h
LcapY       equ     059h
LcapZ       equ     05Ah
La          equ     061h
Lb          equ     062h
Lc          equ     063h
Ld          equ     064h
Le          equ     065h
L_f         equ     066h
Lg          equ     067h
Lh          equ     068h
L_i         equ     069h
Lj          equ     06Ah
Lk          equ     06Bh
Ll          equ     06Ch
Lm          equ     06Dh
Ln          equ     06Eh
Lo          equ     06Fh
Lp          equ     070h
Lq          equ     071h
Lr          equ     072h
Ls          equ     073h
Lt          equ     074h
Lu          equ     075h
Lv          equ     076h
Lw          equ     077h
Lx          equ     078h
Ly          equ     079h
Lz          equ     07Ah

kF1         equ     0C2h
kF2         equ     0C3h
kF3         equ     0C4h
kF4         equ     0C5h
kF5         equ     0C6h
kExit       equ     007h
kEnter      equ     006h
kClear      equ     008h
kDel        equ     009h
kRight      equ     001h
kLeft       equ     002h
kUp         equ     003h
kDown       equ     004h
kMore       equ     00Bh
k0          equ     01Ch
k1          equ     01Dh
k2          equ     01Eh
k3          equ     01Fh
k4          equ     020h
k5          equ     021h
k6          equ     022h
k7          equ     023h
k8          equ     024h
k9          equ     025h
kSpace      equ     027h
kCapA       equ     028h
kCapB       equ     029h
kCapC       equ     02Ah
kCapD       equ     02Bh
kCapE       equ     02Ch
kCapF       equ     02Dh
kCapG       equ     02Eh
kCapH       equ     02Fh
kCapI       equ     030h
kCapJ       equ     031h
kCapK       equ     032h
kCapL       equ     033h
kCapM       equ     034h
kCapN       equ     035h
kCapO       equ     036h
kCapP       equ     037h
kCapQ       equ     038h
kCapR       equ     039h
kCapS       equ     03Ah
kCapT       equ     03Bh
kCapU       equ     03Ch
kCapV       equ     03Dh
kCapW       equ     03Eh
kCapX       equ     03Fh
kCapY       equ     040h
kCapZ       equ     041h
ka          equ     042h
kb          equ     043h
kc          equ     044h
kd          equ     045h
ke          equ     046h
kf          equ     047h
kg          equ     048h
kh          equ     049h
ki          equ     04Ah
kj          equ     04Bh
kk          equ     04Ch
kl          equ     04Dh
km          equ     04Eh
kn          equ     04Fh
ko          equ     050h
kp          equ     051h
kq          equ     052h
kr          equ     053h
ks          equ     054h
kt          equ     055h
ku          equ     056h
kv          equ     057h
kw          equ     058h
kx          equ     059h
ky          equ     05Ah
kz          equ     05Bh


