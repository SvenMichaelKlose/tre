;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun compile-argument-expansion-defaults (defaults)
  (mapcar (fn `(& (eq ,_ ,(list 'quote _))
			      (= ,_ ,(assoc-value _ defaults))))
		  (carlist defaults)))

(defun compile-argument-expansion-0 (adef p &optional (argdefs nil) (key-args nil))
  (with ((argdefs key-args) (make-&key-alist adef)
		 get-name    [? (cons? _.) _.. _.]
		 get-default [? (cons? _.) (cadr _.) _.]

		 key
		   #'(()
			    (& key-args '((keywords))))

		 static
		   #'((def)
			    `((= ,def. (car ,p))
				  (= ,p (cdr ,p))
				  ,@(main .def)))

		 optional
		   #'((def)
			    `(,@(key)
				  (? ,p
				     (= ,(get-name def) (car ,p)
				        ,p (cdr ,p))
					 ,@(& (cons? def.)
					      `((= ,(get-name def) ,(get-default def)))))
				  ,@(& .def
					   (? (argument-keyword? .def.)
				  		  (main .def)
					      (optional .def)))))

		 arest
		   #'((def)
			    `(,@(key)
				  (= ,def. ,p)))

         optional-rest
		   #'((def)
		        (case def.
				  '&rest     (arest .def)
				  '&body     (arest .def)
				  '&optional (optional .def)))

		 sub
		   #'((def)
			    `(,@(key)
				  (with-temporary ,p (car ,p)
				    ,@(compile-argument-expansion-0 def. p))
				  (= ,p (cdr ,p))
				  ,@(main .def)))

		 main
		   #'((def)
				(?
				  (not def)					nil
				  (argument-keyword? def.)	(optional-rest def)
				  (cons? def.)				(sub def)
				  (static def))))
   (? key-args
      `((with (keywords
				  #'(()
                      (block compexp
				        (let v nil
					      (while (keyword? (= v (car ,p)))
							     nil
						    (?
						      ,@(mapcan (fn `((eq v ,(make-symbol (symbol-name _) *keyword-package*))
											  (= ,p (cdr ,p)
											     ,_ (car ,p)
												 ,p (cdr ,p))))
									    (carlist key-args))
						      (return-from compexp nil)))))))
          ,@(& argdefs (main argdefs))
		  ,@(key)
		  ,@(compile-argument-expansion-defaults key-args)))
       (main argdefs))))

(defun compile-argument-expansion-function-body (fun-name adef p toplevel-continuer names)
  `(with ,(mapcan (fn `(,_ ,(list 'quote _))) names)
     ,@(compile-argument-expansion-0 adef p)
     ((%transpiler-native ,(compiled-function-name *transpiler* fun-name)) ,@toplevel-continuer ,@names)))

(defun compile-argument-expansion-cps (this-name fun-name adef names)
  (with-gensym (toplevel-continuer p)
    `(function ,this-name
               ((,p)
                  (let ,toplevel-continuer ~%continuer
                    ,(compile-argument-expansion-function-body fun-name adef p (list toplevel-continuer) names))))))

(defun compile-argument-expansion-no-cps (this-name fun-name adef names)
  (with-gensym p
    `(function ,this-name
               ((,p)
                  ,(compile-argument-expansion-function-body fun-name adef p nil names)))))

(defun only-&rest? (adef)
  (& (== 2 (length adef))
     (eq '&rest adef.)))

(defun compile-argument-expansion (this-name fun-name adef)
  (? (only-&rest? adef)
	 fun-name
     (alet (argument-expand-names 'compile-argument-expansion adef)
       (funcall (? (in-cps-mode?)
                   #'compile-argument-expansion-cps
                   #'compile-argument-expansion-no-cps)
                this-name fun-name adef !)
	   fun-name)))
