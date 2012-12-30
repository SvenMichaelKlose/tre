;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-compiled-literal (name (x table) &key maker init-maker decl-maker)
  "Define a collector of declarations and initializations for literals of a particular data type."
  (let slot `(,($ 'transpiler-compiled- table 's) *current-transpiler*)
    `(defun ,name (,x)
       (let tr *current-transpiler*
         (| (href ,slot ,x)
	 	    (let n ,maker
	          ,@(& decl-maker
                   `((push (funcall ,decl-maker n) (transpiler-compiled-decls tr))))
              (push `(= ,,n ,init-maker) (transpiler-compiled-inits tr))
              (= (href ,slot ,x) n)))))))
