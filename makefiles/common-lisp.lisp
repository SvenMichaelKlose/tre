; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(alet (copy-transpiler *cl-transpiler*)
  (= (transpiler-save-sources? !) nil)
  (with-output-file o "tre.lisp"
    (filter [late-print _ o]
            (compile-sections (list (. 'core *cl-base*))
                              :transpiler !))))
(quit)
