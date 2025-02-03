; TODO: Revive bytecode target to get this back.

(var *eval-transpiler* nil)

(fn make-eval-transpiler ()
  (cache *eval-transpiler*
         (!= (copy-transpiler *bc-transpiler*)
           (= (transpiler-import-from-host? !) nil
              (transpiler-dump-passes? !)      nil)
              *eval-transpiler*                !)))

(defmacro with-mute-environment (&body x)
  `(with-temporaries (*print-definitions?*  nil
                      *print-notes?*        nil
                      *print-status?*       nil)
     ,@x))

(fn late-eval (x)
  (with-gensym tmpfun
    (!= (make-eval-transpiler)
      (clr (transpiler-global-inits !))
      (with-mute-environment
        (load-bytecode (expr-to-code ! (compile-sections :sections   `((eval . ((fn ,tmpfun () ,x))))
                                                         :transpiler !))
                       :temporary? t))
      (~> (symbol-function tmpfun)))))
