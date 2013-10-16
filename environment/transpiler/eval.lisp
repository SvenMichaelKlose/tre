;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *eval-transpiler* nil)

(defun make-eval-transpiler ()
  (| *eval-transpiler*
     (alet (copy-transpiler *bc-transpiler*)
       (transpiler-reset !)
       (clr (transpiler-only-environment-macros? !)
            (transpiler-import-from-environment? !)
            (transpiler-dump-passes? !)
            (expex-warnings? (transpiler-expex !)))
       (= *eval-transpiler* !))))

(defun late-eval (x)
  (with-gensym tmpfun
    (alet (make-eval-transpiler)
      (clr (transpiler-frontend-files !)
           (transpiler-compiled-files !)
           (transpiler-raw-decls !))
      (with-temporaries (*show-definitions?* nil
                         *show-transpiler-progress?* nil)
        (load-bytecode (expr-to-code ! (compile-sections `((eval . ((defun ,tmpfun () ,x))))
                                                         :transpiler !))
                       :temporary? t))
      (funcall (symbol-function tmpfun)))))
