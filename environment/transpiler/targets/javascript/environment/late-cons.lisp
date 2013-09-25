;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun car (x)
  (? x
     (? (atom x)
        (error "Cons or NIL expected instead of ~A.")
        x._)))

(defun cdr (x)
  (? x
     (? (atom x)
        (error "Cons or NIL expected instead of ~A.")
        x.__)))

(defun cpr (x)
  (? x
     (? (atom x)
        (error "Cons or NIL expected instead of ~A.")
        x._p)))

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
     (%%%== x.__class ,(obfuscated-symbol-string 'cons))))
