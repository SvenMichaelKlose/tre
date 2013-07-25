; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

atom_alloc:
.(
        lda atoms_free
        sta p
        cmp atom_size
        bcs page_too_small
enough_space:
        ldy #0
        lda atom_size
        sta (p),y
        clc
        adc atoms_ptr
        sta atoms_ptr
        bcs pagewrap
        rts
pagewrap:
        inc atoms_free+1
        rts

page_too_small:
        lda atoms_free+1
        sta p+1
        bne enough_space
        
out_of_atoms:
        lda #<txt_out_of_atoms
        ldy #>txt_out_of_atoms
        jsr console
        jmp exit
.)
