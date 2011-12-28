;;;;; tré - Copyright (c) 2006,2009,2011 Sven Klose <pixel@copei.de>

(defun (setf car) (val lst)
  (rplaca lst val)
  val)

(defun (setf cdr) (val lst)
  (rplacd lst val)
  val)

(defun (setf elt) (val seq idx)
  (%set-elt val seq idx))

(defun (setf aref) (val arr &rest idx)
  (apply #'%set-aref val arr idx))

(defun (setf caar) (val lst)
  (rplaca (car lst) val)
  val)

(defun (setf cadr) (val lst)
  (rplaca (cdr lst) val)
  val)

(defun (setf cdar) (val lst)
  (rplacd (car lst) val)
  val)

(defun (setf cddr) (val lst)
  (rplacd (cdr lst) val)
  val)

(defun (setf caddr) (val lst)
  (rplaca (cddr lst) val)
  val)
