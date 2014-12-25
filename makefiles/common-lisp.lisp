; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(alet (copy-transpiler *cl-transpiler*)
  (= (transpiler-import-from-environment? !) nil)
  (with-output-file o "tre.lisp"
    (filter [late-print _ o]
            (cdar (compile-sections (list (. 'core *cl-base*))
                                     :transpiler !)))))
(quit)
