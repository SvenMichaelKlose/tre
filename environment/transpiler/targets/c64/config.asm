tmp         = 2     ; Temporary byte.
p           = 3     ; Address pointer.
v           = $fb   ; Return value.
;$fd-$fe

s           = 3     ; Stack pointer.
atom_size   = $07
atoms_free  = $0b
atoms_ptr   = $0d
universe    = $0f
gc_level    = $11

; $11-$12
; $14-$2a
; $2d-72
; $8b-$90

free_conses = $b0

cons_start  = $8000
cons_end    = $ffff
atoms_start = $4000
atoms_end   = $8000
