;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun car (x)
  (when x
    (x.get-car)))

(defun cdr (x)
  (when x
    (x.get-cdr)))

(defun rplaca (x val)
  (declare type cons x)
  (x.set-car val)
  x)

(defun rplacd (x val)
  (declare type cons x)
  (x.set-cdr val)
  x)

(defun consp (x)
  (is_a x "__cons"))
