; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

gc:
.(
    lda universe
    sta p
    lda universe+1
    sta p+1

    jsr vstack_call
    .word mark
    rts

mark:
    ldy #1
    lda (p),y
    bpl mark_atom

    ldy #0          ; Check if cons is already marked.
    lda (p),y       ; (Set 0th bit in CAR.
    tax
    and #1
    bne already_marked_cons

    txa             ; Mark this cons.
    ora #1
    sta (p),y

    jsr vstack_push_p

    ldy #0          ; Get CAR.
    lda (p),y
    tax
    iny
    lda (p),y
    sta p
    stx p+1

    jsr vstack_call ; Mark it.
    .word mark

    jsr vstack_current_p; Return to this cons.

    ldy #2          ; Get CDR.
    lda (p),y
    tax
    iny
    lda (p),y
    sta p+1
    stx p

    jsr vstack_call ; Mark it.
    .word mark

    jsr vstack_pop_p; Return to this cons.

already_marked_cons:
mark_atom:
    ldy #0          ; Check if cons is already marked.
    lda (p),y       ; (Set 0th bit in CAR.
    tax
    and #1
    bne already_marked_atom

    txa             ; Mark this atom.
    ora #1
    sta (p),y

    ; Mark atom content.

already_marked_atom:
    jmp vstack_return
.)

sweep:
    ; Set pointer to start of pool.
    lda #<atoms
    sta tmp
    sta p
    lda #>atoms
    sta tmp+1
    sta p+1

    ; Find marked atom.
find_marked:
    ldy #0
    lda (p),y
    bit #1
    bne found_marked

    clc     ; Jump over atom.
    adc p
    sta p
    lda p+1
    adc #0
    sta p+1
    cmp #>atoms_end
    beq rts

    ; Unless same address...
    lda p
    cmp tmp
    bne move_atom
    lda p+1
    cmp tmp+1
    beq find_marked

    ; Add pointers to relocation table.
    lda p
    sta (reloc),y
    lda p+1
    iny
    sta (reloc),y
    lda tmp
    iny
    sta (reloc),y
    lda tmp+1
    iny
    sta (reloc),y

    ; Copy atom.
    lda (p),y
    tay
    tax
c:  lda (p),y
    sta (tmp),y
    dey
    bpl c

    ; Advance pointers.
    txa
    clc
    adc tmp
    sta tmp
    lda tmp+1
    adc #0
    sta tmp+1

    txa
    clc
    adc p
    sta p
    lda p+1
    adc #0
    sta p+1

    ; Relocate and restart if relocation table is full.
    inc reloc
    bcc find_marked


