; tré – Copyright (c) 2011–2014 Sven Michael Klose <pixel@copei.de>

(defvar *eval-transpiler* nil)

(defun make-eval-transpiler ()
  (| *eval-transpiler*
     (alet (copy-transpiler *bc-transpiler*)
       (transpiler-reset !)
       (clr (transpiler-only-environment-macros? !)
            (transpiler-import-from-host? !)
            (transpiler-dump-passes? !)
            (expex-warnings? (transpiler-expex !)))
       (= *eval-transpiler* !))))

(defmacro with-mute-environment (&body x)
  `(with-temporaries (*print-definitions?*         nil
                      *print-notes?*               nil
                      *print-status?*              nil)
     ,@x))

(defun late-eval (x)
  (with-gensym tmpfun
    (alet (make-eval-transpiler)
      (clr (transpiler-cached-frontend-sections !)
           (transpiler-cached-output-sections !)
           (transpiler-raw-decls !))
      (with-mute-environment
        (load-bytecode (expr-to-code ! (compile-sections `((eval . ((defun ,tmpfun () ,x))))
                                                         :transpiler !))
                       :temporary? t))
      (funcall (symbol-function tmpfun)))))
