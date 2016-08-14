; tré – Copyright (c) 2005–2006,2009,2012–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun multiple-value-bind-0 (forms gl body)
  (? forms
     (with-gensym gn
       `((let* ((,forms. (car ,gl))
		        ,@(& .forms
			         `((,gn ,(? *assert?*
						        `(| (cdr ,gl)
                                    (%error "Not enough VALUES."))
						        `(cdr ,gl))))))
	       ,@(multiple-value-bind-0 .forms gn body))))
	 body))

(defmacro multiple-value-bind (forms expr &body body)
  (with-gensym (g gl)
    `(let* ((,g   ,expr)
	        (,gl  (cdr ,g)))
	   ,@(& *assert?*
            `((unless (eq (car ,g) 'values)
         	    (error "VALUES expected instead of ~A." ,g))))
       ,@(multiple-value-bind-0 forms gl body))))
