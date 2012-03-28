;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Klose <pixel@copei.de>

(defun car (x) (when x x._))
(defun cdr (x) (when x x.__))

(defvar *rplaca-breakpoints* nil)
(defvar *rplacd-breakpoints* nil)

(defun rplaca (x val)
  (declare type cons x)
  (when-debug
    (when (member x *rplaca-breakpoints* :test #'eq)
      (invoke-debugger)))
  (setf x._ val)
  x)

(defun rplacd (x val)
  (declare type cons x)
  (when-debug
    (when (member x *rplacd-breakpoints* :test #'eq)
      (invoke-debugger)))
  (setf x.__ val)
  x)

(defun cons? (x)
  (and (object? x)
	   x.__class
	   (%%%= x.__class ,(transpiler-obfuscated-symbol-string *current-transpiler* 'cons))))
