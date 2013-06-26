;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

main:
    cli
    lda #$7f
    sta $dc0d     ; Disable timer interrupts because ROMs are not visible.
    lda #<txt_welcome
    ldy #>txt_welcome
    jsr console
    jsr cons_init
exit:
    lda #<txt_exit
    ldy #>txt_exit
    jsr console
    jsr roms_on
    lda #$81
    sta $dc0d     ; Re-enable timer interrupts.
    sti
    rts

txt_welcome
    .asc "TRE8 REVISION 1 <PIXEL@COPEI.DE>", $0d
    .asc "COPYRIGHT (C) 2013 SVEN MICHAEL KLOSE", $0d, 0

txt_exit
    .asc "BACK TO THE ROOTS.", 0
