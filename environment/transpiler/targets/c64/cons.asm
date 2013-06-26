;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

free_conses = $b0
cons_start  = $8000
cons_end    = $ffff

;; Line up free conses in a singly–linked list.
cons_init:
        lda #<txt_cons_init
        ldy #>txt_cons_init
        jsr console
        lda #0              ; Make Y register our pointer's low byte.
        tay
        sta p
        pha
        pha
        lda #>cons_start    ; Set start page of conses.
        sta p+1
        ldx #>(cons_start-cons_end) ; Load X register with number of pages.
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

txt_cons_init:
        .asc "INITIALIZING CONSES..." , $0d, 0

car:    .word $caca
cdr:    .word $cdcd

;; Allocate a cons.
cons:   lda free_conses+1   ; Get the new cons into our pointer.
        beq out_of_conses
        sta p+1
        lda free_conses
        sta p
        ldy #0
        lda (p),y           ; Save the address of the next free cons.
        sta free_conses
        iny
        lda (p),y
        sta free_conses+1
        lda car             ; Copy CAR and CDR into the cons.
        dey
        sta (p),y
        lda car+1
        iny
        sta (p),y
        lda cdr
        iny
        sta (p),y
        lda cdr+1
        iny
        sta (p),y
        rts                 ; Done.

out_of_conses:
        lda #<txt_nocons
        ldy #>txt_nocons
        jsr console
f1:     rts

txt_nocons:
        .asc "OUT OF CONSES", 0

;; Free a cons.
uncons: lda free_conses
        ldy #0
        sta (p),y
        lda free_conses+1
        iny
        sta (p),y
        lda p
        sta free_conses
        lda p+1
        sta free_conses+1                                                                                                          
        rts
