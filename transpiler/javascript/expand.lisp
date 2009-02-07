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
(defun js-essential-defun (name args &rest body)
  (print `(defun ,name))
  (with (n (%defun-name name)
		 tr *js-transpiler*)
    (transpiler-obfuscate-symbol tr n)
    (transpiler-add-function-args tr n args)
	(transpiler-add-defined-function tr n)
    `(progn
       (%var ,n)
       (%setq ,n
	          #'(,args
   		           ,@(if (and (not *assert*)
		    	              (stringp body.))
				         .body
				         body))))))

(define-js-std-macro define-native-js-fun (name args &rest body)
  (apply #'js-essential-defun name args body))

(define-js-std-macro defun (name args &rest body)
  (with-gensym g
	(let n (%defun-name name)
      `(progn
		 (%var ,g)
	     (%setq ,g (%lookup-symbol ,(symbol-name n) nil))
	     ,(apply #'js-essential-defun name args body)
		 (setf (symbol-function ,g) ,n)))))

(define-js-std-macro defmacro (name &rest x)
  (print `(defmacro ,name ))
  (eval (transpiler-macroexpand *js-transpiler*
								`(define-js-std-macro ,name ,@x)))
  nil)

(define-js-std-macro defvar (name val)
  (let tr *js-transpiler*
    (print `(defvar ,name))
    (when (transpiler-defined-variable tr name)
      (error "variable ~A already defined" name))
    (transpiler-add-defined-variable tr name)
    (transpiler-obfuscate-symbol tr name)
    `(progn
       (%var ,name)
	   (%setq ,name ,val))))

(define-js-std-macro make-string (&optional len)
  "")

(define-js-std-macro funcall (fun &rest x)
  `(,fun ,@x))

;; Translate SLOT-VALUE to unquoted variant.
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
		 ,@(aif (transpiler-function-arguments *js-transpiler* x.)
		       (argument-expand-compiled-values x. ! .x)
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

; XXX generic function instead of append!
(define-js-std-macro dont-obfuscate (&rest symbols)
  (append! (transpiler-obfuscation-exceptions *js-transpiler*) symbols)
  nil)
