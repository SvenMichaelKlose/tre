(fn %environment-transpiler (tr funs)
  (aprog1 (copy-transpiler tr)
    (with-temporary *transpiler* !
      (add-wanted-functions (| (ensure-list funs)
                               (carlist (+ *functions* *macros*)))))))

(fn compile-c-environment (&optional (funs nil))
  (put-file "environment/transpiler/targets/c/native/_compiled-env.c"
            (compile-sections nil :transpiler (%environment-transpiler *c-transpiler* funs)))
  nil)

(fn compile-bytecode-environment (&optional (funs nil))
  (alet (%environment-transpiler (eval '*bc-transpiler*) funs)
    (expr-to-code ! (compile-sections nil :transpiler !))))

(fn compile-c-compiler ()
  (compile-c-environment '(generic-compile)))

(fn compile-bytecode-compiler ()
  (compile-bytecode-environment '(generic-compile)))
