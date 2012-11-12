;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun car (x)
  (when x
    (assert-method x a)
    (x.a)))

(defun cdr (x)
  (when x
    (assert-method x d)
    (x.d)))

(defun rplaca (x val)
  (assert-method x sa)
  (x.sa val)
  x)

(defun rplacd (x val)
  (assert-method x sd)
  (x.sd val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
