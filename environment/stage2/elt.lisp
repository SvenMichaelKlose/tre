(fn %=-elt-string (val seq idx)
  (error "Cannot modify strings."))

(fn elt (seq idx)
  (?
    (string? seq)  (%elt-string seq idx)
    (cons? seq)    (nth idx seq)
    (aref seq idx)))

(fn (= elt) (val seq idx)
  (?
    (array? seq)   (= (aref seq idx) val)
    (cons? seq)    (rplaca (nthcdr idx seq) val)
    (string? seq)  (error "Strings cannot be modified.")
    (error "Not a sequence: ~A" seq)))
