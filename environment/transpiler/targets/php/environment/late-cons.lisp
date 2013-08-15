;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(= (symbol-function 'cons) "userfun_cons")

(defun car (x)
  (when x
    (assert-method x a)
    (x.a)))

(defun cdr (x)
  (when x
    (assert-method x d)
    (x.d)))

(defun cpr (x)
  (when x
    (assert-method x d)
    (x.p)))

(defun rplaca (x val)
  (assert-method x sa)
  (x.sa val)
  x)

(defun rplacd (x val)
  (assert-method x sd)
  (x.sd val)
  x)

(defun rplacp (x val)
  (assert-method x sd)
  (x.sp val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
