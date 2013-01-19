;;;;; tré – Copyright (c) 2088–2013 Sven Michael Klose

(defun concat-successive-strings (x)
  (with (rec #'((x y)
                  (?
	                (not x)      (!? y (list !))
	                (not x.)     (rec .x nil)
	                (string? x.) (? y
	                                (rec .x (string-concat y x.))
   	  	                            (rec .x x.))
	                y            (cons y (cons x. (rec .x nil)))
	                (cons x. (rec .x nil)))))
    (rec x nil)))

(defun opt-string-concat (x op)
  (?
    (not .x) x.
    (some #'string? x) (alet (concat-successive-strings x)
                         (? .!
                            `(string-concat ,@!)
                            !.))
    `(,op ,@x)))
