;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

main:
    cli
    lda #$7f
    sta $dc0d     ; Disable timer interrupts because ROMs are not visible.
    lda #<txt_welcome
    ldy #>txt_welcome
    jsr console
    jsr cons_init
    jmp exit
