;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(define-js-std-macro %defsetq (&rest x)
  `(progn
	 (%var ,x.)
	 (%setq ,@x)))

(defun js-make-function-with-compiled-argument-expansion (x)
  (let g '~%cargs
    (with-lambda-content x fi args body
      `(#'((,g)
	        (= ,g ,(copy-lambda `(function ,x) :body (body-with-noargs-tag body)))
		    (= (slot-value ,g 'tre-exp) ,(compile-argument-expansion g args))
		    ,g)
		  nil))))

(transpiler-wrap-invariant-to-binary define-js-std-macro eq 2 eq &)

(define-js-std-macro not (&rest x)
  (funcall #'shared-not x))

(define-js-std-macro function (x)
  (? (cons? x)
     (with-lambda-content x fi args body
	   (? (| (body-has-noargs-tag? body)
             (simple-argument-list? args))
  	      `(function ,x)
		  (js-make-function-with-compiled-argument-expansion x)))
  	 `(function ,x)))

(define-js-std-macro funcall (fun &rest args)
  (with-gensym (f e a)
    `(with (,f ,fun
            ,e (slot-value ,f 'tre-exp))
       (? ,e
          (let ,a (list ,@args)
            ((slot-value ,e 'apply) nil (%transpiler-native "[" ,a "]")))
          (,f ,@args)))))

(defvar *late-symbol-function-assignments* nil)

(defun js-make-late-symbol-function-assignment (name)
  (push `(= (slot-value ',name 'f) ,(compiled-function-name *transpiler* name))
        *late-symbol-function-assignments*))

(defun emit-late-symbol-function-assignments ()
  (reverse *late-symbol-function-assignments*))

(define-js-std-macro define-native-js-fun (name args &rest body)
  (js-make-late-symbol-function-assignment name)
  `(progn
     ,@(apply #'shared-defun name args (body-with-noargs-tag body))))

(defun js-early-symbol-maker (g sym)
   `(,@(unless (eq g '~%tfun)
         `((%var ,g)))
     (%setq ,g (symbol ,(transpiler-obfuscated-symbol-name *transpiler* sym)
                       ,(awhen (symbol-package sym)
                          `(make-package ,(transpiler-obfuscated-symbol-name *transpiler* !)))))))

(define-js-std-macro defun (name args &rest body)
  (let dname (apply-current-package (transpiler-package-symbol *js-transpiler* (%defun-name name)))
    (let g '~%tfun
      `(progn
         ,@(js-early-symbol-maker g dname)
         ,@(apply #'shared-defun dname args body)
         (= (symbol-function ,g) ,dname)))))

(define-js-std-macro %defun (&rest x)
  `(defun ,@x))

(define-js-std-macro defmacro (&rest x)
  (apply #'shared-defmacro x))

(define-js-std-macro defvar (name &optional (val '%%no-value))
  (funcall #'shared-defvar name val))

(define-js-std-macro defconstant (&rest x)
  `(defvar ,@x))

(define-js-std-macro %%u=-car (val x)
  (shared-=-car val x))

(define-js-std-macro %%u=-cdr (val x)
  (shared-=-cdr val x))

(define-js-std-macro make-string (&optional len)
  "")

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,.slot.))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

(defun js-transpiler-make-new-hash (x)
  `(%%%make-hash-table
	 ,@(mapcan [list (? (& (not (string? _.))
						   (eq :class _.))
					    "class" ; IE6 wants this.
					    _.)
					 ._.]
			   (group x 2))))

(defun js-transpiler-make-new-object (x)
  `(%new ,@x))

(define-js-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (? (| (keyword? x.)
	    (string? x.))
	 (js-transpiler-make-new-hash x)
	 (js-transpiler-make-new-object x)))

(define-js-std-macro js-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(? (< 1 (length types))
       	   `(| ,@(filter ^(%%%== (%js-typeof x) ,_) types))
           `(%%%== (%js-typeof x) ,types.)))))

(define-js-std-macro %href (hash key)
  `(aref ,hash ,key))

(define-js-std-macro undefined? (x)
  `(%%%== "undefined" (%js-typeof ,x)))

(define-js-std-macro defined? (x)
  `(%%%!= "undefined" (%js-typeof ,x)))

(define-js-std-macro dont-obfuscate (&rest symbols)
  (print-definition `(dont-obfuscate ,@symbols))
  (apply #'transpiler-add-obfuscation-exceptions *transpiler* symbols)
  nil)

(define-js-std-macro dont-inline (&rest x)
  (dolist (i x)
    (transpiler-add-inline-exception *transpiler* i))
  nil)

(define-js-std-macro assert (x &optional (txt nil) &rest args)
  (when (transpiler-assert? *transpiler*)
    (make-assertion x txt args)))

(define-js-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan ^(,_ ',_) .lexicals.)
                        ,fun))))

(define-js-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-js-std-macro string-concat (&rest x)
  `(%%%+ ,@x))

(define-js-std-macro functional (&rest x)
  (print-definition `(functional ,@x))
  (= *functionals* (nconc x *functionals*))
  nil)

(define-js-std-macro in-package (n)
  (= (transpiler-current-package *transpiler*) (& n (make-package (symbol-name n))))
  `(%%in-package ,n))

(define-js-std-macro invoke-debugger ()
 `(%setq nil (%invoke-debugger)))

(define-js-std-macro define-test (&rest x))

;(define-js-std-macro filter (fun lst)
  ;(shared-opt-filter fun lst))
