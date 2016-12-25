(defun (= car) (val lst)
  (rplaca lst val)
  val)

(defun (= cdr) (val lst)
  (rplacd lst val)
  val)

(defun (= elt) (val seq idx)
  (%set-elt val seq idx))

(defun (= caar) (val lst)
  (rplaca (car lst) val)
  val)

(defun (= cadr) (val lst)
  (rplaca (cdr lst) val)
  val)

(defun (= cdar) (val lst)
  (rplacd (car lst) val)
  val)

(defun (= cddr) (val lst)
  (rplacd (cdr lst) val)
  val)

(defun (= caddr) (val lst)
  (rplaca (cddr lst) val)
  val)
