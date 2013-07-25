;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

;; Line up free conses in a singly–linked list.
cons_init:
        lda #<txt_cons_init
        ldy #>txt_cons_init
        jsr console
        lda #0      ; Make Y register our pointer's low byte.
        tay
        sta p
        pha
        pha
        lda #>cons_start    ; Set start page of conses.
        sta p+1
        ldx #>(cons_start-cons_end) ; Load X register with number of pages.
.(
l1:     pla         ; Save pointer to previous cons in CAR of this one.
        sta (p),y
        pla
        iny
        sta (p),y
        dey         ; Point back to start of cons.
        lda p+1     ; Push current pointer on the stack,
        pha
        tya
        pha
        iny         ; Increment to next cons.
        iny
        iny
        iny
        bne l1
        dex
        beq e1
        inc p+1     ; Increment to next page.
        jmp l1      ; No, continue.

e1:     pla
        pla
        lda #<cons_end-3
        sta free_conses
        lda #>cons_end
        sta free_conses+1
        rts
.)
