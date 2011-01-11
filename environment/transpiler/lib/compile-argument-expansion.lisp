;;;;; TRE environment
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Argument expansion compiler

(defun compile-argument-expansion-defaults (defaults)
  (mapcar (fn `(when (eq ,_ ,(list 'quote _))
			     (setf ,_ ,(assoc-value _ defaults))))
		  (carlist defaults)))

(defun compile-argument-expansion-0 (adef p &optional (argdefs nil)
								   					  (key-args nil))
  (with ((argdefs key-args) (argument-exp-sort adef)
		 get-name
		   #'((def)
				(if (consp def.)
				    def..
					def.))

		 get-default
		   #'((def)
				(if (consp def.)
				    (cadr def.)
					def.))

		 compexp-key
		   #'(()
			    (when key-args
				  '((compexp-keywords))))

		 compexp-static
		   #'((def)
			    `(,@(compexp-key)
				  (setf ,def. (car ,p))
				  (setf ,p (cdr ,p))
				  ,@(compexp-main .def)))

		 compexp-optional
		   #'((def)
			    `(,@(compexp-key)
				  (if ,p
				      (setf ,(get-name def) (car ,p)
				            ,p (cdr ,p))
					  ,@(when (consp def.)
					      `((setf ,(get-name def)
								  ,(get-default def)))))
				  ,@(when .def
					  (if (argument-keyword? .def.)
				  		  (compexp-main .def)
					      (compexp-optional .def)))))

		 compexp-rest
		   #'((def)
			    `(,@(compexp-key)
				  (setf ,def. ,p)))

         compexp-optional-rest
		   #'((def)
		        (case def.
				  '&rest		(compexp-rest .def)
				  '&body		(compexp-rest .def)
				  '&optional	(compexp-optional .def)))

		 compexp-sub
		   #'((def)
			    `(,@(compexp-key)
				  (with-temporary ,p (car ,p)
				    ,@(compile-argument-expansion-0 def. p))
				  (setf ,p (cdr ,p))
				  ,@(compexp-main .def)))

		 compexp-main
		   #'((def)
				(if
				  (not def)					nil
				  (argument-keyword? def.)	(compexp-optional-rest def)
				  (consp def.)				(compexp-sub def)
				  (compexp-static def))))
   (if key-args
       `((with (compexp-keywords
				   #'(()
				       (let v nil
					     (while (keywordp (setf v (car ,p)))
								nil
						   (if
						     ,@(mapcan (fn `((eq v ,(make-symbol (symbol-name _) *keyword-package*))
											 (setf ,p (cdr ,p)
												   ,_ (car ,p)
												   ,p (cdr ,p))))
									   (carlist key-args)))))))
           ,@(when argdefs
			   (compexp-main argdefs))
		   ,@(compexp-key)
		   ,@(compile-argument-expansion-defaults key-args)))
        (append (compexp-main argdefs)
		        (compile-argument-expansion-defaults key-args)))))

(defun compile-argument-expansion-function-body (fun-name adef p toplevel-continuer names)
  `(with ,(mapcan (fn `(,_ ,(list 'quote _)))
	              names)
     ,@(compile-argument-expansion-0 adef p)
     ((%transpiler-native ,(compiled-function-name fun-name)) ,@toplevel-continuer ,@names)))

(defun compile-argument-expansion (fun-name adef)
  (if (and (= 2 (length adef))
		   (eq '&rest adef.))
	  (list 'function fun-name)
      (let-if names (argument-expand-names 'compile-argument-expansion adef)
          (with-gensym p
            (if (in-cps-mode?)
                (with-gensym toplevel-continuer
                  (print `#'((,p)
                       (let ,toplevel-continuer ~%continuer
                         ,(compile-argument-expansion-function-body fun-name adef p (list toplevel-continuer) names)))))
                `#'((,p)
                     ,(compile-argument-expansion-function-body fun-name adef p nil names))))
	      (list 'function fun-name))))
