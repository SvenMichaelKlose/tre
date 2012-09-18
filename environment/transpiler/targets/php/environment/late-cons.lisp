;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun car (x)
  (assert-slot-if-not-nil x a)
  (& x (x.a)))

(defun cdr (x)
  (assert-slot-if-not-nil x d)
  (& x (x.d)))

(defun rplaca (x val)
  (assert-slot x sa)
  (x.sa val)
  x)

(defun rplacd (x val)
  (assert-slot x sd)
  (x.sd val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
