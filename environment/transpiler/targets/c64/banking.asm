;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>
;;
;; ROM banking

roms_on:
    pha
    lda #%00110111  ; Default.
roms_switch:
    sta 1
    pla
    rts

roms_off:
    pha
    lda #%00110000
    jmp roms_switch
