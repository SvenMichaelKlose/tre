;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

;; Define macro that is expanded _before_ standard macros.
(defmacro define-js-std-macro (&rest x)
  `(define-transpiler-std-macro *js-transpiler* ,@x))

(defun transpiler-obfuscate-arguments (tr x)
  (dolist (i (argument-expand 'anonymous-function x nil nil))
    (transpiler-obfuscate-symbol tr i)))

;; (FUNCTION symbol | lambda-expression)
;; Add symbol to list of wanted functions or obfuscate arguments of
;; LAMBDA-expression.
;; XXX Wouldn't this obfuscate the arguments over and over again?
(define-js-std-macro function (x)
  (unless x
    (error "FUNCTION expects a symbol or form"))
  (if (atom x)
	  (transpiler-add-wanted-function *js-transpiler* x)
      (transpiler-obfuscate-arguments *js-transpiler* x.))
  `(function ,x))

;; (DEFUN ...)
;;
;; Assign function to global variable.
;; XXX This could be generic if there wasn't *JS-TRANSPILER*.
;; XXX Reunite with DEFUN macro.
(define-js-std-macro js-defun (name args &rest body)
  (print `(defun ,name))
  (let n (%defun-name name)
    (transpiler-obfuscate-symbol *js-transpiler* n)
    (acons! n args (transpiler-function-args *js-transpiler*))
	(push! n (transpiler-defined-functions *js-transpiler*))
    `(progn
       (%var ,n)
       (%setq ,n
	          #'(,args
   		           ,@(if (and (not *assert*)
		    	              (stringp body.))
				         .body
				         body))))))

(define-js-std-macro defun (name args &rest body)
  `(progn
     (js-defun ,name ,args ,@body)
	 (%setq (%slot-value ,(%defun-name name) tre-args) ',args)))

(define-js-std-macro defmacro (name &rest x)
  (print `(defmacro ,name ))
  (eval (transpiler-macroexpand *js-transpiler*
								`(define-js-std-macro ,name ,@x)))
  nil)

(define-js-std-macro defvar (name val)
  (print `(defvar ,name))
  (transpiler-obfuscate-symbol *js-transpiler* name)
  `(progn
     (%var ,name)
	 (%setq ,name ,val)))

(define-js-std-macro make-string (&optional len)
  `"")

;; XXX This is the same like it is in the environment.
;; XXX Try to get along without it.
(define-js-std-macro defstruct (name &rest fields-and-options)
  (apply #'%defstruct-expander name fields-and-options))

(define-js-std-macro funcall (fun &rest x)
  `(,fun ,@x))

;; XXX Isn't this already in the environment?
(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

;; XXX Can't we do this in one macro?
(define-js-std-macro bind (fun &rest args)
  (unless (%slot-value? fun)
    (error "function must be a SLOT-VALUE, got ~A" fun))
  `(%bind ,(second fun) ,fun))

;; X-browser MAKE-HASH-TABLE.
(defun js-transpiler-make-new-hash (x)
  `(make-hash-table
	 ,@(mapcan (fn (list (if (and (not (stringp _.))
								  (eq :class _.))
							 "class" ; IE6 wants this.
							 _.)
						 (second _)))
			   (group x 2))))

;; Translate arguments for call to native 'new' operator.
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

;; Iterate over array.
(define-js-std-macro doeach ((var seq &rest result) &rest body)
  (with-gensym (evald-seq idx)
    `(with (,evald-seq ,seq)
	   (dotimes (,idx (%slot-value ,evald-seq length) ,@result)
	     (with (,var (aref ,evald-seq ,idx))
           ,@body)))))

;; Iterate over keys of object.
(define-js-std-macro dohash ((key val hash &rest result) &rest body)
  `(block nil
     (((%transpiler-native "for (" ,key " in " ,seq ")")
	    (%no-expex (with (,var (aref ,seq ,key))
          ,@body))))))

;; Make type predicate function.
(define-js-std-macro js-type-predicate (name type)
  `(defun ,name (x)
     (when x
       (%%%= (%js-typeof x)
          ,(string-downcase (symbol-name (transpiler-obfuscate-symbol *js-transpiler* type)))))))

(define-js-std-macro href (hash key)
  `(aref ,hash ,key))

(define-js-std-macro dont-obfuscate (&rest symbols)
  (append! (transpiler-obfuscation-exceptions *js-transpiler*) symbols)
  nil)
