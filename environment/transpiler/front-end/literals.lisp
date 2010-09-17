;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-expand-characters (x)
  (characterp x)
	`(code-char ,(char-code x)))

(defmacro define-compiled-literal (name (x table) &key maker setter decl-maker)
  "Define collector for declarations and initialisations for a certain
   data type of literals."
  (let slot `(,($ 'transpiler-compiled- table 's) *current-transpiler*)
    `(defun ,name (,x)
       (or (href ,slot ,x)
	 	   (let n ,maker
	         (push! (funcall ,decl-maker n)
  					(transpiler-compiled-decls *current-transpiler*))
	       	 (push! `(setf ,,n ,setter)
  					(transpiler-compiled-inits *current-transpiler*))
	       	 (setf (href ,slot ,x) n))))))
