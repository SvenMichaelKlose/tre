;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

exit:
    lda #<txt_exit
    ldy #>txt_exit
    jsr console
    jsr roms_on
    lda #$81
    sta $dc0d     ; Re-enable timer interrupts.
    sti
    rts
