;;;; TRE environment
;;;; Copyright (c) 2005-2006,2009 Sven Klose <pixel@copei.de>

(defun multiple-value-bind-0 (forms gl body)
  (if forms
	  (with-gensym gn
        `((let* ((,(car forms) (car ,gl))
			     ,@(when (cdr forms)
				     `((,gn ,(if *assert*
							   `(or (cdr ,gl)
							  	    (%error "not enough VALUES"))
							   `(cdr ,gl))))))
	        ,@(multiple-value-bind-0 (cdr forms) gn body))))
	  body))

(defmacro multiple-value-bind (forms expr &rest body)
  (with-gensym (g gl)
    `(let* ((,g ,expr)
	        (,gl (cdr ,g)))
	   ,@(when *assert*
           `((unless (eq (car ,g) 'VALUES)
         	   (%error "VALUES expected"))))
       ,@(multiple-value-bind-0 forms gl body))))

(defun values (&rest vals)
  (cons 'VALUES vals))
