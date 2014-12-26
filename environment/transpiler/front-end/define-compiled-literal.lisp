; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-compiled-literal (name (x table) &key maker init-maker decl-maker)
  "Define a collector of declarations and initializations for literals of a particular data type."
  (let slot `(,($ 'compiled- table 's))
    `(defun ,name (,x)
       (| (href ,slot ,x)
          (let n ,maker
            (unless (funinfo-var? (global-funinfo) n)
              (add-literal n)
              (funinfo-var-add (global-funinfo) n))
            ,@(& decl-maker
                 `((push (funcall ,decl-maker n) (compiled-decls))))
            (push `(= ,,n ,(list 'quasiquote init-maker)) (compiled-inits))
            (= (href ,slot ,x) n))))))
