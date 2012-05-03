;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun car (x) (when x (x.a)))
(defun cdr (x) (when x (x.d)))

(defun rplaca (x val)
  (x.sa val)
  x)

(defun rplacd (x val)
  (x.sd val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
