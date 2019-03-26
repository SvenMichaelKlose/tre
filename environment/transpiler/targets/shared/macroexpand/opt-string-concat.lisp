; tré – Copyright (c) 2088–2013,2015 Sven Michael Klose <pixel@hugbox.org>

(defun concat-successive-strings (x)
  (& x
     (? (& (string? x.)
           (string? .x.))
        (concat-successive-strings (. (string-concat x. .x.) ..x))
        (. x. (concat-successive-strings .x)))))

(defun opt-string-concat (x op)
  (?
    (not .x) x.
    (some #'string? x) (alet (concat-successive-strings x)
                         (? .!
                            `(string-concat ,@!)
                            !.))
    `(,op ,@x)))
