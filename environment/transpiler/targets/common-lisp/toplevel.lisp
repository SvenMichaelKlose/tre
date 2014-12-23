; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(defun tre-expansions (x)
  (backquote-expand (quasiquote-expand (macroexpand (dot-expand x)))))
(defun expr2cl (x)                 (make-lambdas (tre-expansions x)))
(defun file2cl (pathname)          (expr2cl (read-file pathname)))
(defun files2cl (&rest pathnames)  (. 'progn (mapcan #'file2cl pathnames)))
