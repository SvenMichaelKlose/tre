;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun car (x) (when x x.car))
(defun cdr (x) (when x x.cdr))

(defun rplaca (x val)
  (declare type cons x)
  (setq x.car val)
  x)

(defun rplacd (x val)
  (declare type cons x)
  (setq x.cdr val)
  x)

(defun cons? (x)
  (is_a x "__cons"))
