; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defmacro define-compiled-literal (name (x table) &key maker init-maker decl-maker)
  (let slot `(,($ 'compiled- table 's))
    `(defun ,name (,x)
       (cache (aprog1 ,maker
                (unless (funinfo-var? (global-funinfo) !)
                  (add-literal !)
                  (funinfo-var-add (global-funinfo) !))
                ,@(& decl-maker
                     `((push (funcall ,decl-maker !) (compiled-decls))))
                (push `(= ,,! ,(list 'quasiquote init-maker)) (compiled-inits)))
              (href ,slot ,x)))))
