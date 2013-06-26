;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

; Print to console.
;
; YA: Address of ASCIIZ string.
console:
    stx tmp
    jsr roms_on
    jsr $ab1e
    jsr roms_off
    ldx tmp
    rts
