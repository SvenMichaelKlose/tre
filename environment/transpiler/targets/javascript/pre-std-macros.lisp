;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-pre-std-macro (&rest x)
  `(define-transpiler-pre-std-macro *js-transpiler* ,@x))
