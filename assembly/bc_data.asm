

;* BUCK DATA
;*****************************************************

    jp bc_data_end  ;just in case!
;defines of program settings------------------------------------------------
;   NOTE: this is useful as a quick overview of program limits and settings
;   NOTE: some routines reference these settings, but not all of them (yet)
;#define DEBUG   ;turn debugging on or off by un/commenting this line

;program versioning data
#define _version_ID_name    "%btcv600"  ;TIOS variable holding the ID code
#define _version_ID_code    "aaa000"    ;(6 characters)
#define _welcome_text       "Bucking             Calculator          ver 6.0 alpha" ;the text displayed on the main screen

;program names
pname_MainBuckingCalculator: .db 4,"BC60"
pname_BCLengthPriceEditor: .db 5,"BCLP2"
pname_BCSetup: .db 6,"BCStup"
pname_BCStatisticsProcessor: .db 6,"bcstpr" ;this and below are TIBASIC programs
pname_BCStatisticsViewer: .db 6,"bcstat"
pname_BCStatisticsUndoer: .db 6,"bcstun"
pname_BCStatisticsMillChooser: .db 7,"bchmill"

;Buck algorithm constraints
#define _maximum_top_diameter   32      ;inches
#define _minimum_top_diameter   1       ;inches     {not used yet}
#define _maximum_log_length     40      ;feet       {not used yet}
#define _minimum_log_length     ;determined at runtime based on LCV data
#define _minimum_log_length     ;TODO
#define _maximum_log_price      ;TODO
#define _maximum_log_volume     ;TODO

;user interface settings
#define _allow_BCLP2_criteria_traversal 1  

;general data settings
#define _bcout_rows 5           ;bcout is the algorithm matrix output to TIOS
#define _bcout_columns 6        ;   see the OutputResults routine for more info
#define _statdata_rows 6        ;bcmill1, bcmill2, and bcmill3
#define _statdata_columns 20    ;   total length of the LCV

;general data names
output_matrix_name: .db 5,"bcout"   ;results matrix exported by BC
mill1_matrix_name: .db 7,"bcmill1"  ;statdata matrix names
mill2_matrix_name: .db 7,"bcmill2"
mill3_matrix_name: .db 7,"bcmill3"
millcopy_matrix_name: .db 6,"bcsave"
mill1_name_var: .db 8,"bcmill1n"   ;statdata mill name storage variables
mill2_name_var: .db 8,"bcmill2n"
mill3_name_var: .db 8,"bcmill3n"
millcopy_name_var: .db 7,"bcsaven"

;general data
mill_fill_name: .db "------  ",0  ;NOTE: mill name data regions are same size
                    
;bucking algorithm error status
err_occured: .db 0 ;status whether or not any errors transpired

;[BEGIN SAVEABLE]===============================================================
data_start:

TamperChk_firstrun_status: .db 1        ;set if program has never run before

;multiple mills-----------------------------------------------
mill1_name: .db "mill a  ",0  ;NOTE: ALL mill name data regions must same size
mill1_number: .db 0
mill1_distance: .db 0
prices_mill1: .dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
LCV_mill1: .db 1,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255
minmax_td_mill1: .dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;min/max td critria
mill1_LCV_size: .db 0 ;number of elements (starting from 0) in the LCV
mill2_name: .db "rsg     ",0  
mill2_number: .db 1
mill2_distance: .db 0
prices_mill2: .dw 300,300,475,475,475,475,475,475,475,475,575,575,625,625,625,0,0,0,0,0
LCV_mill2: .db 15,13,31,29,27,25,23,21,19,17,35,33,41,39,37,255,0,0,0,0,255
minmax_td_mill2: .dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;min/max td critria
mill2_LCV_size: .db 14 ;number of elements (starting from 0) in the LCV
mill3_name: .db "freres  ",0 
mill3_number: .db 2
mill3_distance: .db 0
prices_mill3: .dw 580,580,580,580,580,580,580,580,580,0,0,0,0,0,0,0,0,0,0,0
LCV_mill3: .db 12,13,23,31,39,33,18,27,35,255,0,0,0,0,0,0,0,0,0,0,255
minmax_td_mill3: .dw 8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;min/max td critria
mill3_LCV_size: .db 8 ;number of elements (starting from 0) in the LCV
mill3_end:  ;marks the end of mill3 data
;/multiple mills----------------------------------------------

;mill data---------------------------------------------------------------------
;   NOTE: the mill data must be in the same order as the multiple mills data
mill_name: .db "frer b  ",0      ;zero-terminated, always follow with 
                                 ;  currentmill_number, length is calculated on 
                                 ;  the fly by the price and name editors
currentmill_number: .db 0       ;starts from zero
mill_distance: .db 0

data_LP_start:
;prices: .dw 650,650,650,650,650,650,650,650,650,650,650,650,650,650,650,650,650,650,650,650 
prices: .dw 580,580,580,580,580,580,580,580,580,580,580,580,580,580,580,580,580,580,580,580 
                    ;               #Lengths-to-Check Vector (255 terminated)
                    ;    LCV = [40,38,36,34,32,30,28,26,24,22,20,18,16,255]
;LCV: .db 17,18,19,20,21,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255 ;speed test lengths
LCV: .db 23,31,39,33,18,27,35,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
                    ;   ; __this *needs* to be 255 terminated initially !!!
                        ;   also, trim should be added when this array is input

minmax_td: .dw 8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;min/max top diameter
                                                       ; criteria. In each
                                                       ; element the first byte
                                                       ; is the min diam and the
                                                       ; second byte is the max
LCV_size: .db 6 ;number of elements (starting from 0) in the LCV
data_LP_end:
;/mill data--------------------------------------------------------------------

statistics: .db 0  ;[on/off] [adds/removes complexity from the GUI]
mill_number: .db 0 ;mill to switch to when SwitchMill routine is run
calculation_mode: .db 0 ;0 = basic calculate, 1 = user compare, 2 = mill compare
trucking_cost: .db 0  ;[TODO]

max_length: .db 151 ;[TODO: this should be calculated based on number of LCV 
                    ;           elements and length of tree]
                    ; NOTE: - with log criteria, the efficacy of this is dubious
                    ;       - may be best to implement a background timer that
                    ;           provides an option to cancel execution after a 
                    ;           certain time period has transpired

data_end:
;/[END SAVEABLE]================================================================


;[BEGIN INPUTS]=================================================================
data_inputs_start:
;[NOTE -- (log description arrays) log and log_dia to be requested as inputs]
log: .db 0,150,0,0,0,0
log_dia: .db 30,6,0,0,0,0
length: .db 150 ;[total log length variable]
data_inputs_end:
;/[END INPUTS]==================================================================


;[BEGIN VOLATILE DATA]==========================================================
data_volatile_start:

                    ;
                    ;    it = [255,255,255,255,255,255]  #iteration tracker 
it: .db 255,255,255,255,255,255;            #(this currently is used to track 
                    ;                       # index of LCV)
                    ;LCVcompact is where the LCV is copied when repeat 
                    ;   elements are removed for the statistics matrices
LCVcompact: .db 17,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,255 
LCVcompact_size: .db 0 ;number of elements (starting from 0) in LCVcompact

;result variable offsets
#define _result_offset_lengths  0
#define _result_offset_sum_p    6
#define _result_offset_p        8
#define _result_offset_v        20
#define _result_offset_td       32
#define _result_offset_siter    38
#define _result_offset_sum_v    39
#define _result_offset_mill_num 41
#define _result_offset_name     42

;   -- order is important
;   NOTE: result variable order must coincide with all other result variables
;   NOTE: the result variable offsets above must correctly indicate variable 
;           locations
;   NOTE: anything between transient_result_vars and firstchoice_result_vars
;           is copied many times during runtime by Buck, this is a speed 
;           consideration
transient_result_vars:
Li: .db 150,0,0,0,0,0;    Li = [L,0,0,0,0,0]             #length iterators
sum_p: .dw 0 
p:  .dw 0,0,0,0,0,0 ;    p = [0,0,0,0,0,0]               #price tracker
v:  .dw 0,0,0,0,0,0 ;    v = [0,0,0,0,0,0]               #volume tracker
td: .db 0,0,0,0,0,0 ;    td = [0,0,0,0,0,0]              #top diameter tracker
status_iterator: .db 0 ;simple storage tracking the all important "s" iterator

;   -- order is important
firstchoice_result_vars:
Lf:  .db 0,0,0,0,0,0;    Lf = [0,0,0,0,0,0]              #lengths tracker
sum_p1: .dw 0
p1: .dw 0,0,0,0,0,0 ;    p1 = [0,0,0,0,0,0]
v1: .dw 0,0,0,0,0,0 ;    v1 = [0,0,0,0,0,0]
td1: .db 0,0,0,0,0,0;    td1 = [0,0,0,0,0,0]
s_iterator1: .db 0 ;simple storage tracking the all important "s" iterator
sum_v1: .dw 0
firstchoice_mill_number: .db 0
firstchoice_result_name: .db 0,0,0,0,0,0,0,0,0

;   -- order is important
secondchoice_result_vars:
Lf2: .db 0,0,0,0,0,0;    Lf2 = [0,0,0,0,0,0]          #secondary lengths tracker
sum_p2: .dw 0
p2: .dw 0,0,0,0,0,0 ;    p2 = [0,0,0,0,0,0]
v2: .dw 0,0,0,0,0,0 ;    v2 = [0,0,0,0,0,0]
td2: .db 0,0,0,0,0,0;    td2 = [0,0,0,0,0,0]
s_iterator2: .db 0 ;simple storage tracking the all important "s" iterator
sum_v2: .dw 0
secondchoice_mill_number: .db 0
secondchoice_result_name: .db 0,0,0,0,0,0,0,0,0


;   -- order is important
user_guess_result_vars:
user_l: .db 0,0,0,0,0,0
user_sum_p: .dw 0
user_p: .dw 0,0,0,0,0,0
user_v: .dw 0,0,0,0,0,0
user_td: .db 0,0,0,0,0,0
s_iteratorU: .db 0 ;simple storage tracking the all important "s" iterator
user_sum_v: .dw 0
user_guess_mill_number: .db 0
user_guess_result_name: .db 0,0,0,0,0,0,0,0,0

                   ;
;[NOTE -- lognum *must* be, at most, one less (starting from 1) than the length]
;[          of the above result arrays!! Minimum limit of 2 -- useful for      ]
;[          debugging                                                          ]
#define _lognum 5   ;    lognum = 5                 #log number control variable
                    ;
#define _trim 1     ;    trim = 1     #(in feet) --> eg. 0.8333 = 10inches

;[NOTE -- log_entries *must* be, at most, one less (starting from 1) than the  ]
;[          length of the input arrays (log, log_dia)!!                        ]
#define _log_entries 5 ;[calculate this on the fly?? -- could make inputs more variable!]

Li[s]_temp: .db 0 ;[temporary storage for Li[s]]
temp: .dw 0       ;[general temporary variable]
                    ;            #  (program determines actual min_length later)
min_length: .db 255 ;    min_length = 255  #minimum log length variable (arbitrary large number)

data_volatile_end:
;/[END VOLATILE DATA]===========================================================


;   -- order is important
mill1_result_vars: ; (these must persist through volatile-data wipes)
mill1_l: .db 0,0,0,0,0,0
mill1_sum_p: .dw 0
mill1_p: .dw 0,0,0,0,0,0
mill1_v: .dw 0,0,0,0,0,0
mill1_td: .db 0,0,0,0,0,0
s_iterator_m1: .db 0 ;simple storage tracking the all important "s" iterator
mill1_sum_v: .dw 0
mill1_mill_number: .db 0
mill1_result_name: .db 0,0,0,0,0,0,0,0,0
 
;   -- order is important
mill2_result_vars: ; (these must persist through volatile-data wipes)
mill2_l: .db 0,0,0,0,0,0
mill2_sum_p: .dw 0
mill2_p: .dw 0,0,0,0,0,0
mill2_v: .dw 0,0,0,0,0,0
mill2_td: .db 0,0,0,0,0,0
s_iterator_m2: .db 0 ;simple storage tracking the all important "s" iterator
mill2_sum_v: .dw 0
mill2_mill_number: .db 1
mill2_result_name: .db 0,0,0,0,0,0,0,0,0
 
;FinDisplay data
FinDisplay_data_pointer:    .dw 0   ;pointer to the display data
FinDisplay_unit_designator: .db 0   ;unit symbol to be displayed in the top row
#define _FinDisplay_offset_col1_data     0
#define _FinDisplay_offset_col2_data     2
#define _FinDisplay_offset_col3_data     4
#define _FinDisplay_offset_col_head      6
#define _FinDisplay_offset_top_row       7
#define _FinDisplay_offset_table_body    8
#define _FinDisplay_offset_x_check_array 9
FinDisplay3_basic_display:  
    .dw firstchoice_result_vars,secondchoice_result_vars,0
    .db _result_offset_name,_result_offset_sum_p,_result_offset_lengths
    .db _result_offset_p
guess_text: .db "guesses",0
FinDisplay3_usercompare_display: 
    .dw user_guess_result_vars,firstchoice_result_vars,secondchoice_result_vars
    .db _result_offset_name,_result_offset_sum_p,_result_offset_lengths
    .db _result_offset_p
FinDisplay3_millcompare_display: 
    .dw mill1_result_vars,mill2_result_vars,firstchoice_result_vars
    .db _result_offset_name,_result_offset_sum_p,_result_offset_lengths
    .db _result_offset_p

;bigmessage option data
no_text: .db "       NO       ",0
cancel_text: .db "   CANCEL  ",0
continue_text: .db "  CONTINUE ",0
okay_text: .db "    OKAY   ",0
save_text: .db "    SAVE   ",0

;menumessage data
inputsomething_message: .db "       Input   Something",0
toobig_message: .db "      Number   Too   Big",0
noroom_message: .db "       No   More   Room",0
pressenter_message: .db "          Press    Enter!",0
notimplemented_message: .db "Not   Implemented",0

;simple strings for general use
none_text: .db "none",0
empty_text: .db " ",0
clearselection_text: .db "     ",0
working_text: .db "Working...",0

bc_data_end:
