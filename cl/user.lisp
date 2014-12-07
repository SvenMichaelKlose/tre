;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre)

(%defun eval (x) (%eval x))
(%defun string (x) (%string x))
(%defun eq (&rest x) (apply #'%eq (list x)))
(%defun eql (&rest x) (apply #'%eql (list x)))
(%defun not (&rest x) (apply #'%not x))
(%defun make-symbol (x &optional (package nil)) (%make-symbol x package))
(%defun symbol-value (x) (%symbol-value x))
(%defun symbol-function (x) (%symbol-function x))
(%defun symbol-package (x) (%symbol-package x))
(%defun number? (x) (%number? x))
(%defun integer (x) (%integer x))
(%defun number+ (&rest x) (apply #'%+ x))
(%defun integer+ (&rest x) (apply #'%+ x))
(%defun character+ (&rest x) (apply #'%+ x))
(%defun number- (&rest x) (apply #'%- x))
(%defun integer- (&rest x) (apply #'%- x))
(%defun character- (&rest x) (apply #'%- x))
(%defun * (&rest x) (apply #'%* x))
(%defun / (&rest x) (apply #'%/ x))
(%defun < (&rest x) (apply #'%< x))
(%defun > (&rest x) (apply #'%> x))
(%defun filter (fun x) (mapcar fun x))
(%defun make-array (&optional (dimensions 1)) (%make-array dimensions))
(%defun make-hash-table (&key (test #'eql)) (%make-hash-table :test test))

(%defvar *macroexpand-hook* nil)

(%defun macroexpand-1 (x)
  (? *macroexpand-hook*
     (apply *macroexpand-hook* (list x))
     x))

(%defun macroexpand-0 (old x)
  (? (%equal x old)
     old
     (macroexpand x)))

(%defun macroexpand (x)
  (macroexpand-0 x (macroexpand-1 x)))

(%defun nanotime () 0)
(%defun function-bytecode (x) x nil)


(env-load "stage0-cl/main.lisp")
(env-load "main.lisp")
