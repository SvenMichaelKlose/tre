;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *eval-transpiler* nil)

(defun make-eval-transpiler ()
  (| *eval-transpiler*
     (let tr (copy-transpiler *bc-transpiler*)
       (transpiler-reset tr)
       (clr (transpiler-only-environment-macros? tr)
            (transpiler-import-from-environment? tr)
            (transpiler-dump-passes? tr)
            (transpiler-expex-warnings? tr))
       (= *eval-transpiler* tr))))

(defun late-eval (x)
  (with-gensym tmpfun
    (let tr (make-eval-transpiler)
      (clr (transpiler-frontend-files tr)
           (transpiler-compiled-files tr)
           (transpiler-raw-decls tr))
      (with-temporaries (*show-definitions?* nil
                         *show-transpiler-progress?* nil)
        (load-bytecode (bc-transpile `((eval . ((defun ,tmpfun () ,x))))
                                     :transpiler tr)
                       :temporary? t))
      (funcall (symbol-function tmpfun)))))
