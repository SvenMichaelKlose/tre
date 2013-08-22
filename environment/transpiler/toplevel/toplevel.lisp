;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-code (tr forms)
  (transpiler-backend tr (transpiler-middleend tr forms)))

(defun transpiler-make-toplevel-function (tr)
  `((defun accumulated-toplevel ()
      ,@(reverse (transpiler-accumulated-toplevel-expressions tr)))))
