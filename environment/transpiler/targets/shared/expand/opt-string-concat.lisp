;;;;; tré - Copyright (c) 2088-2012 Sven Michael Klose

(defun opt-string-concat (x op)
  (?
    (not .x) x.
    (every #'string? x) (apply #'string-concat x)
    (some #'string? x) (alet (string-concat-successive-literals x)
                         (? .!
                            `(string-concat ,@!)
                            !.))
    `(,op ,@x)))
