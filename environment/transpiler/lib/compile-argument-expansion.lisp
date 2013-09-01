;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun compile-argument-expansion-defaults (defaults)
  (mapcar (fn `(& (eq ,_ ,(list 'quote _))
			      (= ,_ ,(assoc-value _ defaults))))
		  (carlist defaults)))

(defun compile-argument-expansion-0 (adef p &optional (argdefs nil) (key-args nil))
  (with ((argdefs key-args) (make-&key-alist adef)

		 key
		   #'(()
			    (& key-args '((keywords))))

		 static
           [`((= ,_. (car ,p))
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
		   [`(,@(key)
			  (= ,_. ,p))]

         optional-rest
		   [case _.
			 '&rest     (arest ._)
			 '&body     (arest ._)
			 '&optional (optional ._)]

		 sub
           [`(,@(key)
			  (with-temporary ,p (car ,p)
			    ,@(compile-argument-expansion-0 _. p))
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
  (? (only-&rest? adef)
	 fun-name
     (alet (argument-expand-names 'compile-argument-expansion adef)
       (funcall (? (in-cps-mode?)
                   #'compile-argument-expansion-cps
                   #'compile-argument-expansion-no-cps)
                this-name fun-name adef !))))
