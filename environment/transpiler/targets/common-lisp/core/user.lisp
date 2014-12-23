;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre)

(%defun string (x) (%string x))
(%defun code-char (x) (%code-char (%integer x)))
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
(%defun load (pathname) (%load pathname))

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
