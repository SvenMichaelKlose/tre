;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

;; Define macro that is expanded _before_ standard macros.
(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(defun transpiler-obfuscate-arguments (tr x)
  (dolist (i (argument-expand 'unnamed-js-function x nil nil))
    (transpiler-obfuscate-symbol *js-transpiler* i)))

(define-js-std-macro function (x)
  (unless x
    (error "FUNCTION expects a symbol or form"))
  (if (atom x)
	  (transpiler-add-wanted-function *js-transpiler* x)
      (transpiler-obfuscate-arguments *js-transpiler* x.))
  `(function ,x))

(define-js-std-macro defun (name args &rest body)
  (print `(defun ,name))
  (let n (%defun-name name)
    (transpiler-obfuscate-symbol *js-transpiler* n)
    (unless (in? n 'apply)
      (acons! n args (transpiler-function-args tr)))
    `(progn
       (%var ,n)
       (%setq ,n
	          #'(,args
   		           ,@(if (and (not *assert*)
		    	              (stringp body.))
				         .body
				         body))))))

(define-js-std-macro defmacro (name &rest x)
  (print `(defmacro ,name ))
  (eval (macroexpand `(define-js-std-macro ,name ,@x)))
  nil)

(define-js-std-macro defvar (name val)
  (print `(defvar ,name))
  (transpiler-obfuscate-symbol *js-transpiler* name)
  `(progn
     (%var ,name)
	 (%setq ,name ,val)))

(define-js-std-macro defstruct (name &rest fields-and-options)
  (apply #'%defstruct-expander name fields-and-options))

(define-js-std-macro dont-obfuscate (&rest symbols)
  (append! (transpiler-obfuscation-exceptions tr) symbols)
  nil)

(define-js-std-macro funcall (fun &rest x)
  `(,fun ,@x))

(define-js-std-macro apply (&rest x)
  `(%apply ,@x))

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

(define-js-std-macro bind (fun &rest args)
  (unless (%slot-value? fun)
    (error "function must be a SLOT-VALUE, got ~A" fun))
  `(%bind ,(second fun) ,fun))

(defun js-transpiler-make-new-hash (x)
  `(make-hash-table
	 ,@(mapcan (fn (list (if (and (not (stringp _.))
								  (eq :class _.))
							 "class" ; IE6 wants this.
							 _.)
						 (second _)))
			   (group x 2))))

(defun js-transpiler-make-new-object (x)
  `(%new ,x.
		 ,@(if (transpiler-function-arguments? *js-transpiler* x.)
		       (argument-expand-compiled-values
			       x.
			       (transpiler-function-arguments *js-transpiler* x.)
			       .x)
			   .x)))

;; Make object if first argument is not a keyword, or string.
(define-js-std-macro new (&rest x)
  (if (and (consp x)
		   (or (keywordp x.)
			   (stringp x.)))
	  (js-transpiler-make-new-hash x)
	  (js-transpiler-make-new-object x)))

(define-js-std-macro doeach ((var seq &rest result) &rest body)
  (with-gensym (evald-seq idx)
    `(with (,evald-seq ,seq)
	   (dotimes (,idx (%slot-value ,evald-seq length) ,@result)
	     (with (,var (aref ,evald-seq ,idx))
           ,@body)))))

(define-js-std-macro dohash ((key val hash &rest result) &rest body)
  `(block nil
     (((%transpiler-native "for (" ,key " in " ,seq ")")
	    (%no-expex (with (,var (aref ,seq ,key))
          ,@body))))))

(define-js-std-macro js-type-predicate (name type)
  `(defun ,name (x)
     (= (%js-typeof x)
        ,(string-downcase (symbol-name (transpiler-obfuscate-symbol *js-transpiler* type))))))
