;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-std-macro (name args &body body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,@body))

(defun js-make-function-with-expander (x)
  (alet (| (lambda-name x)
           (gensym))
    (with-gensym g
      `(%%block
         (%var ,g)
         ,(copy-lambda x :name ! :body (body-with-noargs-tag (lambda-body x)))
         (= (slot-value ,! 'tre-exp) ,(compile-argument-expansion g ! (lambda-args x)))
         ,!))))

(defun js-requires-expander? (x)
  (& (not (body-has-noargs-tag? (lambda-body x)))
     (| (transpiler-assert? *transpiler*)
        (not (simple-argument-list? (lambda-args x))))))

(define-js-std-macro function (&rest x)
  (alet (cons 'function x)
    (? .x
       (? (js-requires-expander? !)
          (js-make-function-with-expander !)
          !)
       !)))

(defvar *late-symbol-function-assignments* nil)

(defun js-make-late-symbol-function-assignment (name)
  (push `(= (slot-value ',name 'f) ,(compiled-function-name name))
        *late-symbol-function-assignments*))

(defun emit-late-symbol-function-assignments ()
  (reverse *late-symbol-function-assignments*))

(define-js-std-macro define-native-js-fun (name args &body body)
  (js-make-late-symbol-function-assignment name)
  `(progn
     (%var ,(%defun-name name))
     ,(shared-defun name args (body-with-noargs-tag body))))

(defun js-early-symbol-maker (g sym)
   `(,@(unless (eq g '~%tfun)
         `((%var ,g)))
     (%= ,g (symbol ,(obfuscated-symbol-name sym)
                       ,(!? (symbol-package sym)
                            `(make-package ,(obfuscated-symbol-name !)))))))

(define-js-std-macro defun (name args &body body)
  (with (dname (apply-current-package (transpiler-package-symbol *js-transpiler* (%defun-name name)))
         g     '~%tfun)
      `(%%block
         (%var ,dname)
         ,@(js-early-symbol-maker g dname)
         ,(shared-defun dname args body :make-expander? nil)
         (= (symbol-function ,g) ,dname))))

(define-js-std-macro %defun (name args &body body)
  `(defun ,name ,args ,@body))

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,.slot.))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "Function must be a SLOT-VALUE, got ~A." fun))
		  ,fun))

(define-js-std-macro new (&rest x)
  (| x (error "Argument(s) expected."))
  (? (| (keyword? x.)
	    (string? x.))
     `(%%%make-hash-table ,@x)
     `(%new ,@x)))

(define-js-std-macro js-type-predicate (name &rest types)
  `(progn
     (declare-cps-exception ,name)
     (defun ,name (x)
       (when x
	     ,(? (< 1 (length types))
       	     `(| ,@(filter ^(%%%== (%js-typeof x) ,_) types))
             `(%%%== (%js-typeof x) ,types.))))))

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
 `(%= nil (%invoke-debugger)))

(define-js-std-macro define-test (&rest x))
