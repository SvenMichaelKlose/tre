; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defun compile-argument-expansion-defaults (defaults)
  (@ [`(& (eq ,_ ,(list 'quote _))
          (= ,_ ,(assoc-value _ defaults)))]
     (carlist defaults)))

(defun compile-argument-expansion-0 (fun-name adef p)
  (with ((argdefs key-args) (make-&key-alist adef)

		 key
		   #'(()
			    (& key-args '((keywords))))

		 static
           [`(,@(? (assert?)
                   `((| ,p
                        (error-arguments-missing ,(symbol-name _.) ',fun-name))))
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
               (error-&rest-has-value fun-name))
            `(,@(key)
			  (= ,_. ,p)
              ,@(? (assert?)
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

(defun compile-argument-expansion-function-body-0 (fun-name adef p names)
  `(,@(compile-argument-expansion-0 fun-name adef p)
    ,@(? (assert?)
         `((? ,p
              (error-too-many-arguments ,(symbol-name fun-name) ,p))))
    ((%%native ,(compiled-function-name fun-name)) ,@names)))

(defun compile-argument-expansion-function-body (fun-name adef p)
  (body-with-noargs-tag
    (!? (argument-expand-names 'compile-argument-expansion adef)
        `((with ,(mapcan [`(,_ ',_)] !)
            ,@(compile-argument-expansion-function-body-0 fun-name adef p !)))
         (compile-argument-expansion-function-body-0 fun-name adef p !))))

(defun compile-argument-expansion-function (this-name fun-name adef)
  (with-gensym p
    `(function ,this-name
               ((,p)
                  ,@(compile-argument-expansion-function-body fun-name adef p)))))

(defun compile-argument-expansion (this-name fun-name adef)
  (compile-argument-expansion-function this-name fun-name adef))
