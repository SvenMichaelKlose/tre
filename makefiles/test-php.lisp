;;;;; tré – Copyright (c) 2008–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defvar *have-environment-tests* t)
(= *show-definitions* t)

(unix-sh-mkdir "compiled")
(alet "compiled/test.php"
  (with-open-file out (open ! :direction 'output)
    (format t "; Compiling to file '~A'...~%" !)
    (princ
      (compile-sections `("makefiles/test-toplevel.lisp")
                        :transpiler *php-transpiler*)
      out)))
