;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

(defmacro define-js-std-macro (name args body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,body))

(define-js-std-macro function (&rest x)
  (with (e `(function ,@x))
    (when (and x
			   (= 1 (length x))
			   (atom x.))
	  (transpiler-add-wanted-function *js-transpiler* x.))
    (unless x
      (error "FUNCTION expects arguments"))
    (if (atom x.)
	    `(function ,x.)

	    (dolist (i (argument-expand 'unnamed-js-function (lambda-args e) nil nil)
				 `(function (,(lambda-args e)
				    ,@(lambda-body e))))
		  (transpiler-obfuscate-symbol *js-transpiler* i)))))

(define-js-std-macro defun (name args &rest body)
  (progn
	(print `(defun ,name))
    (transpiler-obfuscate-symbol *js-transpiler* name)
	(unless (in? name 'apply)
	  (acons! name args (transpiler-function-args tr)))
    `(progn
	   (%var ,name)
	   (%setq ,name
		      #'(,args
    		       ,@(if (and (not *assert*)
			    	          (stringp body.))
					     .body
					     body))))))

(define-js-std-macro defmacro (name args &rest body)
  (progn
	(print `(defmacro ,name ))
	(eval (car (macroexpand `(define-js-std-macro ,name ,args ,@body))))
    nil))

(define-js-std-macro defvar (name val)
  (progn
	(print `(defvar ,name))
    (transpiler-obfuscate-symbol *js-transpiler* name)
    `(progn
	   (%var ,name)
	   (%setq ,name  ,val))))

(define-js-std-macro funcall (fun &rest x)
  `(,fun ,@x))

(define-js-std-macro apply (&rest x)
  `(%apply ,@x))

(define-js-std-macro slot-value (place slot)
  `(%slot-value ,place ,(second slot)))

(define-js-std-macro bind (fun &rest args)
  (progn
    (unless (%slot-value? fun)
      (error "function must be a SLOT-VALUE"))
    `(%bind ,(second fun) ,fun)))

;; Make object if first argument is not a keyword, or string.
(define-js-std-macro new (&rest x)
  (if (and (consp x)
		   (or (keywordp x.)
			   (stringp x.)))
	  `(make-hash-table
		 ,@(mapcan (fn (list (if (and (not (stringp _.))
									  (eq :class _.))
								 "class" ; IE6 wants this.
								 _.)
							 (second _)))
				   (group x 2)))
	  `(%new ,x.
			 ,@(if (transpiler-function-arguments? *js-transpiler* x.)
			       (argument-expand-compiled-values
				       x.
				       (transpiler-function-arguments *js-transpiler* x.)
				       .x)
				   .x))))

(define-js-std-macro doeach ((var seq &rest result) &rest body)
  (with-gensym (evald-seq idx)
    `(with (,evald-seq ,seq)
	   (dotimes (,idx (slot-value ,evald-seq 'length) ,@result)
	     (with (,var (aref ,evald-seq ,idx))
           ,@body)))))

(define-js-std-macro dohash ((key val hash &rest result) &rest body)
  `(block nil
     (((%transpiler-native "for (" ,key " in " ,seq ")")
	    (%no-expex (with (,var (aref ,seq ,key))
          ,@body))))))
