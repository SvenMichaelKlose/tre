(var *eval-transpiler* nil)

(fn make-eval-transpiler ()
  (cache (alet (copy-transpiler *bc-transpiler*)
           (transpiler-reset !)
           (clr (transpiler-import-from-host? !)
                (transpiler-dump-passes? !))
           (= *eval-transpiler* !))
         *eval-transpiler*))

(defmacro with-mute-environment (&body x)
  `(with-temporaries (*print-definitions?*  nil
                      *print-notes?*        nil
                      *print-status?*       nil)
     ,@x))

(fn late-eval (x)
  (with-gensym tmpfun
    (alet (make-eval-transpiler)
      (clr (transpiler-cached-frontend-sections !)
           (transpiler-cached-output-sections !)
           (transpiler-raw-decls !))
      (with-mute-environment
        (load-bytecode (expr-to-code ! (compile-sections `((eval . ((fn ,tmpfun () ,x))))
                                                         :transpiler !))
                       :temporary? t))
      (funcall (symbol-function tmpfun)))))
