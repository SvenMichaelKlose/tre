;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun car (x) (when x x._))
(defun cdr (x) (when x x.__))

(defun rplaca (x val)
  (declare type cons x)
  (setf x._ val)
  x)

(defun rplacd (x val)
  (declare type cons x)
  (setf x.__ val)
  x)

(defun consp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class ,(transpiler-obfuscated-symbol-string
							*current-transpiler* 'cons))))
