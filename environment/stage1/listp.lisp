(functional list?)

(%defun list? (x)
  (? (cons? x)
     t
     (not x)))
