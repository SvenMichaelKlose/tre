; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

; Requires atom_size to be set.
atom_alloc:
.(
        lda #1
        sta gc_level
retry:  ldy #0
        lda atoms_free+1
        sta p+1
        cmp atoms_end
        bcs out_of_atoms
        lda atoms_free
        sta p
        lda atom_size
        sta (p),y
        adc atoms_free
        sta atoms_free
        bcc done
        inc atoms_free+1
done:   rts

out_of_atoms:
        jsr retry ; gc
        jmp retry
.)
