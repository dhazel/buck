

;============================================================
; CriteriaPassFail -- checks to see if a given log passes 
;           the criteria settings
;  input:   B == index location of criteria data (indexed from zero)
;           D == log top diameter
;  output:  carry flag set if criteria check fails
;           carry flag reset if criteria check passes
;  affects: HL <- address of max top diameter criteria
;           A <- destroyed
;  total: 37b
;  tested: yes
;============================================================
CriteriaPassFail:
    ld hl,minmax_td
    call ArryAccessW_ne ;[access current LCV index's criteria values]
    ld a,(hl)
    cp 0    ;[check to make sure there is a criteria]
    jp z,CriteriaPassFail_min_passed ;[if none, pass by default]
    cp d    ;[compare dia with mindiam]
    jp z,CriteriaPassFail_min_passed
    jp nc,CriteriaPassFail_failed ;[if mindiam is greater, skip this length]
CriteriaPassFail_min_passed:
    inc hl
    ld a,(hl)
    cp 0    ;[check to make sure there is a criteria]
    jp z,CriteriaPassFail_max_passed
    cp d    ;[compare dia with mindiam]
    jp c,CriteriaPassFail_failed ;[if maxdiam is less, skip this length]
CriteriaPassFail_max_passed:
    jp CriteriaPassFail_passed
CriteriaPassFail_failed:
    scf     ;[this will set the carry flag]
    ret
CriteriaPassFail_passed:
    cp a    ;[this will reset the carry flag]
    ret
    
