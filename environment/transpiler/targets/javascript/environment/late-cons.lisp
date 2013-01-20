;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun car (x) (& x x._))
(defun cdr (x) (& x x.__))
(defun cpr (x) (& x x._p))

(defvar *rplaca-breakpoints* nil)
(defvar *rplacd-breakpoints* nil)
(defvar *rplacp-breakpoints* nil)

(defun rplaca (x val)
  (declare type cons x)
  (when-debug
    (& (member x *rplaca-breakpoints* :test #'eq)
       (invoke-debugger)))
  (= x._ val)
  x)

(defun rplacd (x val)
  (declare type cons x)
  (when-debug
    (& (member x *rplacd-breakpoints* :test #'eq)
       (invoke-debugger)))
  (= x.__ val)
  x)

(defun rplacp (x val)
  (declare type cons x)
  (when-debug
    (& (member x *rplacp-breakpoints* :test #'eq)
       (invoke-debugger)))
  (= x._p val)
  x)

(defun cons? (x)
  (& (object? x)
     x.__class
     (%%%== x.__class ,(transpiler-obfuscated-symbol-string *transpiler* 'cons))))
