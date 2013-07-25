tmp         = 2     ; Temporary byte.
s           = 3     ; Stack pointer.
p           = $fb   ; Address pointer.
v           = $fd   ; Return value.

atom_size   = $07
atoms_free  = $0b
atoms_ptr   = $0d
universe    = $0f

; $07
; $0b-$12
; $14-$2a
; $2d-72
; $8b-$90

free_conses = $b0

cons_start  = $8000
cons_end    = $ffff
atoms_start = $4000
atoms_end   = $8000
