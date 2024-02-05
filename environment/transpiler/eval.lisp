(var *eval-transpiler* nil)

(fn make-eval-transpiler ()
  (cache *eval-transpiler*
         (!= (copy-transpiler *bc-transpiler*)
           (transpiler-reset !)
           (clr (transpiler-import-from-host? !)
                (transpiler-dump-passes? !))
           (= *eval-transpiler* !))))

(defmacro with-mute-environment (&body x)
  `(with-temporaries (*print-definitions?*  nil
                      *print-notes?*        nil
                      *print-status?*       nil)
     ,@x))

(fn late-eval (x)
  (with-gensym tmpfun
    (!= (make-eval-transpiler)
      (clr (transpiler-compiled-inits !))
      (with-mute-environment
        (load-bytecode (expr-to-code ! (compile-sections `((eval . ((fn ,tmpfun () ,x))))
                                                         :transpiler !))
                       :temporary? t))
      (~> (symbol-function tmpfun)))))
