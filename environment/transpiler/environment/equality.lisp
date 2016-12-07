; tré – Copyright (c) 2008–2009,2011–2014,2016 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception %eql eql)

(defun %eql (x y)
  (| x (setq x nil))
  (| y (setq y nil))
  (| (eq x y)
     (?
       (& (integer? x)
          (integer? y))     (integer== x y)
       (& (character? x)
          (character? y))   (character== x y)
       (& (not (character? x))
          (not (character? y))
          (number? x)
          (number? y))      (== x y)
       (& (string? x)
          (string? y))      (string== x y))))

(defun eql (&rest x)
  (adolist (.x t)
    (| (%eql x. !)
       (return))))

(defmacro eql (&rest x)
  (?
    (some #'string? x)     `(string== ,@x)
    (some #'character? x)  `(character== ,@x)
    `(eql ,@x)))
