;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-characters (x)
  "Wrap characters in CODE-CHAR expressions for languages that
   don't support literal characters."
  (if
	(characterp x)
	  `(code-char ,(char-code x))
    (consp x)
	  (cons (transpiler-expand-characters x.)
		    (transpiler-expand-characters .x))
	x))

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
