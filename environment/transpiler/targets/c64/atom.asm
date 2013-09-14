; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

; Requires atom_size to be set.
atom_alloc:
.(
        lda #1
        sta gc_level
retry:  ldy #0
just_take_the_next_page:
        lda atoms_free+1
        sta p+1
        lda atoms_free
        sta p
        cmp atom_size
        bcs page_too_small
        lda atom_size
        sta (p),y
        adc atoms_free
        sta atoms_free
        rts

page_too_small:
        tya
        sta atoms_free
        inc atoms_free+1
        bne just_take_the_next_page
        jsr retry ; gc
        jmp retry
.)
