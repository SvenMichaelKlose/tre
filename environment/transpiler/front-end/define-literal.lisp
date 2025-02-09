(fn make-symbol-identifier (x)
  ($ (!? (symbol-package x)
         (+ (abbreviated-package-name (symbol-name !)) "_p_")
         "")
     x))

(defmacro define-literal (name tr-slot (x)
                          &key maker
                               initializer
                               (declaration nil))
  `(fn ,name (,x)
     (cache (href (,tr-slot) ,x)
            (aprog1 ,maker
              (funinfo-add-var (global-funinfo) !)
              ,@(when declaration
                  `((push (~> ,declaration !)
                          (global-decls))))
              (push `(= ,,! ,(… 'quasiquote initializer))
                    (global-inits))))))
