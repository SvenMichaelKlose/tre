; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

atom_pool_size = atoms_end - atoms_start

atoms_init:
        lda #<atoms_start
        sta atoms_ptr
        lda #>atoms_start
        sta atoms_ptr+1
        lda #<atom_pool_size
        sta atoms_free
        lda #>atom_pool_size
        sta atoms_free+1
        rts
