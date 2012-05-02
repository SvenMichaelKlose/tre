;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(define-js-std-macro %defsetq (&rest x)
  `(progn
	 (%var ,x.)
	 (%setq ,@x)))

(defun js-make-function-with-compiled-argument-expansion (x)
  (let g '~%cargs
    (when (in-cps-mode?)
      (transpiler-add-cps-function *js-transpiler* g))
    (with-lambda-content x fi args body
      `(#'((,g)
	        (setf ,g ,(copy-lambda `(function ,x) :body (body-with-noargs-tag body)))
		    (setf (slot-value ,g 'tre-exp) ,(compile-argument-expansion g args))
		    ,g)
		  nil))))

(define-js-std-macro define-test (&rest x))

(transpiler-wrap-invariant-to-binary define-js-std-macro eq 2 eq and)

(functional %not)

(define-js-std-macro not (&rest x)
  (? .x
     `(%not (list ,@x))
     `(let ,*not-gensym* t
        (? ,x. (setf ,*not-gensym* nil))
        ,*not-gensym*)))

(define-js-std-macro function (x)
  (? (cons? x)
     (with-lambda-content x fi args body
	   (? (or (body-has-noargs-tag? body)
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

(defun js-cps-exception (x)
  (unless (in-cps-mode?)
    (transpiler-add-cps-exception *js-transpiler* (%defun-name x))))

(defvar *late-symbol-function-assignments* nil)

(defun js-make-late-symbol-function-assignment (dname)
  (push `(setf (slot-value ',dname 'f) ,(compiled-function-name *js-transpiler* dname))
        *late-symbol-function-assignments*))

(defun emit-late-symbol-function-assignments ()
  (reverse *late-symbol-function-assignments*))

(define-js-std-macro define-native-js-fun (name args &rest body)
  (js-cps-exception name)
  (let dname (%defun-name name)
    (js-make-late-symbol-function-assignment dname)
    `(progn
       ,@(apply #'shared-essential-defun dname args (body-with-noargs-tag body)))))

(define-js-std-macro cps-mode (x)
  (when *show-definitions*
    (print `(cps-mode ,x)))
  (unless (in? x nil t)
    (error "Expected NIL or T is the only argument."))
  (setf *transpiler-except-cps?* (not x))
  `(%setq %cps-mode ,x))

(defun js-make-early-symbol-expr (g sym)
   `(,@(unless (eq g '~%tfun)
         `((%var ,g)))
     (%setq ,g (symbol ,(transpiler-obfuscated-symbol-name *js-transpiler* sym)
                       ,(awhen (symbol-package sym)
                          `(make-package ,(transpiler-obfuscated-symbol-name *js-transpiler* !)))))))

(defun js-emit-memorized-sources ()
  (clr (transpiler-memorize-sources? *js-transpiler*))
  (mapcar (fn `(%setq (slot-value ,_. '__source) ,(list 'quote ._)))
          (transpiler-memorized-sources *js-transpiler*)))

(define-js-std-macro %defun (&rest x)
  `(defun ,@x))

(define-js-std-macro %defspecial (&rest x))

(define-js-std-macro defmacro (&rest x)
  (apply #'shared-defmacro x))

(define-js-std-macro defvar (name &optional (val '%%no-value))
  (when (eq '%%no-value val)
    (setf val `',name))
  (let tr *js-transpiler*
    (when *show-definitions*
      (late-print `(defvar ,name)))
    (when (transpiler-defined-variable tr name)
      (redef-warn "redefinition of variable ~A.~%" name))
    (transpiler-add-defined-variable tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-js-std-macro defconstant (&rest x)
  `(defvar ,@x))

(define-js-std-macro %%usetf-car (val x)
  (shared-setf-car val x))

(define-js-std-macro %%usetf-cdr (val x)
  (shared-setf-cdr val x))

(define-js-std-macro make-string (&optional len)
  "")

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,.slot.))

(define-js-std-macro bind (fun &rest args)
  `(%bind ,(? (%slot-value? fun)
 			  .fun.
    		  (error "function must be a SLOT-VALUE, got ~A" fun))
		  ,fun))

(define-js-std-macro make-hash-table (&key (test #'eql) (size nil))
  `(%%%make-hash-table))

(defun js-transpiler-make-new-hash (x)
  `(%%%make-hash-table
	 ,@(mapcan (fn list (? (and (not (string? _.))
							    (eq :class _.))
						   "class" ; IE6 wants this.
						   _.)
						._.)
			   (group x 2))))

(defun js-transpiler-make-new-object (x)
  `(%new ,@x))

(define-js-std-macro new (&rest x)
  (unless x
	(error "NEW expects arguments"))
  (? (or (keyword? x.)
		 (string? x.))
	 (js-transpiler-make-new-hash x)
	 (js-transpiler-make-new-object x)))

(define-js-std-macro js-type-predicate (name &rest types)
  `(defun ,name (x)
     (when x
	   ,(? (< 1 (length types))
       	   `(or ,@(mapcar (fn `(%%%= (%js-typeof x) ,_)) types))
           `(%%%= (%js-typeof x) ,types.)))))

(define-js-std-macro %href (hash key)
  `(aref ,hash ,key))

(define-js-std-macro undefined? (x)
  `(= "undefined" (%js-typeof ,x)))

(define-js-std-macro defined? (x)
  `(not (= "undefined" (%js-typeof ,x))))

(define-js-std-macro dont-obfuscate (&rest symbols)
  (when *show-definitions*
    (late-print `(dont-obfuscate ,@symbols)))
  (apply #'transpiler-add-obfuscation-exceptions *js-transpiler* symbols)
  nil)

(define-js-std-macro dont-inline (&rest x)
  (dolist (i x)
    (transpiler-add-inline-exception *js-transpiler* i)
    (transpiler-add-dont-inline *js-transpiler* i))
  nil)

(define-js-std-macro assert (x &optional (txt nil) &rest args)
  (when *transpiler-assert*
    (make-assertion x txt args)))

(define-js-std-macro %lx (lexicals fun)
  (eval (macroexpand `(with ,(mapcan (fn `(,_ ',_)) .lexicals.)
                        ,fun))))

(define-js-std-macro mapcar (fun &rest lsts)
  (apply #'shared-mapcar fun lsts))

(define-js-std-macro string-concat (&rest x)
  `(%%%+ ,@x))

(define-js-std-macro functional (&rest x)
  (when *show-definitions*
    (late-print `(functional ,@x)))
  (setf *functionals* (nconc x *functionals*))
  nil)

(define-js-std-macro in-package (n)
  (setf (transpiler-current-package *js-transpiler*) (when n (make-package (symbol-name n))))
  `(%%in-package ,n))

(define-js-std-macro invoke-debugger ()
 `(%setq nil (%invoke-debugger)))
