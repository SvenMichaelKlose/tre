;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun compile-argument-expansion-defaults (defaults)
  (mapcar [`(& (eq ,_ ,(list 'quote _))
		       (= ,_ ,(assoc-value _ defaults)))]
		  (carlist defaults)))

(defun compile-argument-expansion-0 (fun-name adef p)
  (with ((argdefs key-args) (make-&key-alist adef)

		 key
		   #'(()
			    (& key-args '((keywords))))

		 static
           [`(,@(? (transpiler-assert? *transpiler*)
                   `((| ,p
                        (error "Argument ~A missing in function ~A." ',_. ',fun-name))))
              (= ,_. (car ,p))
              (= ,p (cdr ,p))
              ,@(main ._))]

		 optional
		   [`(,@(key)
              (? ,p
                 (= ,(argdef-get-name _.) (car ,p)
                    ,p (cdr ,p))
                 ,@(& (cons? _.)
                      `((= ,(argdef-get-name _.) ,(argdef-get-default _.)))))
              ,@(& ._
                   (? (argument-keyword? ._.)
                      (main ._)
                      (optional ._))))]

		 arest
		   [(? (cons? _.)
               (error "In function ~A: &REST argument cannot have a default value." fun-name))
            `(,@(key)
			  (= ,_. ,p)
              ,@(? (transpiler-assert? *transpiler*)
                   `((= ,p nil))))]

         optional-rest
		   [case _.
			 '&rest     (arest ._)
			 '&body     (arest ._)
			 '&optional (optional ._)]

		 sub
           [`(,@(key)
			  (with-temporary ,p (car ,p)
			    ,@(compile-argument-expansion-0 fun-name _. p))
			    (= ,p (cdr ,p))
			    ,@(main ._))]

		 main
		   [?
             (not _)                nil
             (argument-keyword? _.) (optional-rest _)
             (cons? _.)             (sub _)
             (static _)])
   (? key-args
      `((with (keywords
				  #'(()
                      (block compexp
				        (let v nil
					      (while (keyword? (= v (car ,p)))
							     nil
						    (?
						      ,@(mapcan [`((eq v ,(make-symbol (symbol-name _) *keyword-package*))
										   (= ,p (cdr ,p)
										      ,_ (car ,p)
											  ,p (cdr ,p)))]
									    (carlist key-args))
						      (return-from compexp nil)))))))
          ,@(& argdefs
               (main argdefs))
		  ,@(key)
		  ,@(compile-argument-expansion-defaults key-args)))
       (main argdefs))))

(defun compile-argument-expansion-function-body (fun-name adef p toplevel-continuer names)
  `(with ,(mapcan [`(,_ ',_)] names)
     ,@(compile-argument-expansion-0 fun-name adef p)
     ,@(? (transpiler-assert? *transpiler*)
          `((? ,p
               (error "Too many arguments to function ~A. Extra arguments are ~A." ',fun-name ,p))))
     ((%%native ,(compiled-function-name *transpiler* fun-name)) ,@toplevel-continuer ,@names)))

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
  (alet (argument-expand-names 'compile-argument-expansion adef)
    (funcall (? (in-cps-mode?)
                #'compile-argument-expansion-cps
                #'compile-argument-expansion-no-cps)
             this-name fun-name adef !)))
