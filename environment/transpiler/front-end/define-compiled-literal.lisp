(defmacro define-compiled-literal (name (x table)
                                   &key maker init-maker (decl-maker nil))
  (let transpiler-slot `(,($ 'compiled- table 's))
    `(fn ,name (,x)
       (cache (href ,transpiler-slot ,x)
              (aprog1 ,maker
                (unless (funinfo-var? (global-funinfo) !)
                  (funinfo-var-add (global-funinfo) !))
                ,@(& decl-maker
                     `((push (~> ,decl-maker !)
                             (compiled-decls))))
                (push `(= ,,! ,(… 'quasiquote init-maker))
                      (compiled-inits)))))))
