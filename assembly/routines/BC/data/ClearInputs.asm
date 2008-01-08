

;============================================================
; ClearInputs -- Clears the user input variables
;  input: data_inputs_end
;         data_inputs_start
;  output: input variables are zeroed
;  affects: assume everthing
;  total: 9b
;  tested: yes
;============================================================
ClearInputs:
    ld b,data_inputs_end - data_inputs_start
    ld hl,data_inputs_start
    call _ld_hl_bz              ;zero out all 'inputs' memory

    ret

