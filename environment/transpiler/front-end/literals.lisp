;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-expand-characters (x)
  (character? x)
	`(code-char ,(char-code x)))

(defmacro define-compiled-literal (name (x table) &key maker init-maker decl-maker)
  "Define a collector of declarations and initializations for literals of a particular data type."
  (let slot `(,($ 'transpiler-compiled- table 's) *current-transpiler*)
    `(defun ,name (,x)
       (or (href ,slot ,x)
	 	   (let n ,maker
	         ,@(when decl-maker
                 `((push (funcall ,decl-maker n) (transpiler-compiled-decls *current-transpiler*))))
	       	 (push `(setf ,,n ,init-maker) (transpiler-compiled-inits *current-transpiler*))
	       	 (setf (href ,slot ,x) n))))))
