;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

;; Allocate a cons.
cons:   lda #1
        sta gc_level
cons_retry:
        lda free_conses+1   ; Get high byte of next free cons.
        beq out_of_conses   ; Out of luck when zero.
        sta p+1             ; O.K. copy it into our pointer.
        lda free_conses     ; Now copy the low byte.
        sta p
        ldy #0              ; Update address of next free cons.
        lda (p),y
        sta free_conses
        iny
        lda (p),y
        sta free_conses+1
        rts

out_of_conses:
        jsr console ; gc
        jmp cons_retry

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
        and #1      ; ...and make it NIL (0 in high byte) or T (1 in high byte).
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
