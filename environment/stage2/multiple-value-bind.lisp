;;;; TRE environment
u;;; Copyright (c) 2005-2006,2009 Sven Klose <pixel@copei.de>

(defun multiple-value-bind-0 (forms gl i body)
  (if forms
      `((let* ((,(car forms) (nth ,i ,gl)))
	      ,@(multiple-value-bind-0 (cdr forms) gl (1+ i) body)))
	  body))

(defmacro multiple-value-bind (forms expr &rest body)
  (with-gensym (g gl)
    `(let* ((,g ,expr)
	        (,gl (cdr ,g)))
       (if (eq (car ,g) 'VALUES)
           ,@(multiple-value-bind-0 forms gl 0 body)
           (%error "VALUES expected")))))

(defun values (&rest vals)
  (cons 'VALUES vals))
