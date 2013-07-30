;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(defun js-make-function-with-compiled-argument-expansion (x)
  (alet (| (lambda-name x) (gensym))
    (with-gensym g
      `(%%block
         (%var ,g)
         ,(copy-lambda x :name ! :body (body-with-noargs-tag (lambda-body x)))
         (= (slot-value ,! 'tre-exp) ,(compile-argument-expansion g ! (lambda-args x)))
         ,!))))

(define-js-std-macro eq (&rest x)
  (? ..x
     `(& (eq ,x. ,.x.)
         (eq ,x. ,@..x))
     `(eq ,@x)))

(define-js-std-macro function (&rest x)
  (alet (cons 'function x)
    (? .x
       (with (args (lambda-args !)
              body (lambda-body !))
         (? (| (body-has-noargs-tag? body)
               (simple-argument-list? args))
            !
            (js-make-function-with-compiled-argument-expansion !)))
       !)))

(define-js-std-macro funcall (fun &rest args)
  (with-gensym (f e a)
    `(with (,f ,fun
            ,e (slot-value ,f 'tre-exp))
       (? ,e
          (let ,a (list ,@args)
            ((slot-value ,e 'apply) nil (%%native "[" ,a "]")))
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
     (%var ,(%defun-name name))
     ,(apply #'shared-defun name args (body-with-noargs-tag body))))

(defun js-early-symbol-maker (g sym)
   `(,@(unless (eq g '~%tfun)
         `((%var ,g)))
     (%setq ,g (symbol ,(transpiler-obfuscated-symbol-name *transpiler* sym)
                       ,(!? (symbol-package sym)
                            `(make-package ,(transpiler-obfuscated-symbol-name *transpiler* !)))))))

(define-js-std-macro defun (name args &rest body)
  (with (dname (apply-current-package (transpiler-package-symbol *js-transpiler* (%defun-name name)))
         g     '~%tfun)
      `(progn
         (%var ,dname)
         ,@(js-early-symbol-maker g dname)
         ,(apply #'shared-defun dname args body)
         (= (symbol-function ,g) ,dname))))

(define-js-std-macro early-defun (&rest x)
  `(defun ,@x))

(define-js-std-macro make-string (&optional len)
  "")

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,.slot.))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "Function must be a SLOT-VALUE, got ~A." fun))
		  ,fun))

(defun js-make-new-hash (x)
  `(%%%make-hash-table
	 ,@(mapcan [list (? (& (not (string? _.))
						   (eq :class _.))
					    "class" ; IE6 wants this.
					    _.)
					 ._.]
			   (group x 2))))

(defun js-make-new-object (x)
  `(%new ,@x))

(define-js-std-macro new (&rest x)
  (| x (error "Argument(s) expected."))
  (? (| (keyword? x.)
	    (string? x.))
	 (js-make-new-hash x)
	 (js-make-new-object x)))

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

(define-js-std-macro string-concat (&rest x)
  `(%%%+ ,@x))

(define-js-std-macro in-package (n)
  (= (transpiler-current-package *transpiler*) (& n (make-package (symbol-name n))))
  `(%%in-package ,n))

(define-js-std-macro invoke-debugger ()
 `(%setq nil (%invoke-debugger)))

(define-js-std-macro define-test (&rest x))
