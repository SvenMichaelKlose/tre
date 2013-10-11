;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-compiled-literal (name (x table) &key maker init-maker decl-maker)
  "Define a collector of declarations and initializations for literals of a particular data type."
  (let slot `(,($ 'transpiler-compiled- table 's) tr)

    `(defun ,name (,x)
       (let tr *transpiler*
         (| (href ,slot ,x)
	 	    (let n ,maker
              (unless (funinfo-var? (transpiler-global-funinfo tr) n)
                (transpiler-add-literal tr n)
                (funinfo-var-add (transpiler-global-funinfo tr) n))
	          ,@(& decl-maker
                   `((push (funcall ,decl-maker n) (transpiler-compiled-decls tr))))
              (push `(= ,,n ,(list 'quasiquote init-maker)) (transpiler-compiled-inits tr))
              (= (href ,slot ,x) n)))))))
