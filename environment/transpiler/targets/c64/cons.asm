;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

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
        rts

out_of_conses:
        lda #<txt_nocons
        ldy #>txt_nocons
        jsr console
        rts

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

;; Test if pointer is a cons.
consp:  lda p+1
        rol         ; Move bit 7 to 0...
        and #1      ; ...and make it NIL (0) or T (1).
        sta v+1
        rts

;; Get first elment of cons.
car:    ldy #0
cxr:    lda (p),y
        sta v
        iny
        lda (p),y
        sta v+1
        rts

;; Get second element of cons.
cdr:    ldy #2
        jmp cxr
