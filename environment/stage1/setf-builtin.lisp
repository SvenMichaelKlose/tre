;;;;; TRE environment
;;;;; Copyright (C) 2006,2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; SETF setters for builtin functions

(defun (setf car) (val lst)
  (rplaca lst val)
  val)

(defun (setf cdr) (val lst)
  (rplacd lst val)
  val)

(defun (setf elt) (val seq idx)
  (%set-elt val seq idx))

(defun (setf aref) (val arr idx)
  (%set-aref val arr idx))

;;; This will go somewhere else.
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
