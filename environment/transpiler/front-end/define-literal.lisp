(fn make-symbol-identifier (x)
  ($ (!? (symbol-package x)
         (+ (abbreviated-package-name (symbol-name !)) "_p_")
         "")
     x))

(defmacro define-literal (name (x table)
                                   &key maker
                                        initializer
                                        (declaration nil))
  (let transpiler-slot `(,($ 'compiled- table 's))
    `(fn ,name (,x)
       (cache (href ,transpiler-slot ,x)
              (aprog1 ,maker
                (unless (funinfo-var? (global-funinfo) !)
                  (funinfo-add-var (global-funinfo) !))
                ,@(when declaration
                     `((push (~> ,declaration !)
                             (compiled-decls))))
                (push `(= ,,! ,(… 'quasiquote initializer))
                      (compiled-inits)))))))
