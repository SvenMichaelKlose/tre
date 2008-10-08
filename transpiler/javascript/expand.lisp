;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

(defmacro define-js-std-macro (name args body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,body))

(define-js-std-macro defun (name args &rest body)
  (progn
     (transpiler-obfuscate-symbol *js-transpiler* name)
	 (unless (in? name 'apply)
	   (acons! name args (transpiler-function-args tr)))
    `(%setq ,name
		    #'(lambda ,args
    		    ,@(if (and (not *assert*)
				    	   (stringp (first body)))
					  (cdr body)
					  body)))))

(define-js-std-macro defmacro (name args &rest body)
  (progn
	(eval (car (macroexpand `(define-js-std-macro ,name ,args ,@body))))
    nil))

(define-js-std-macro defvar (name val)
  (progn
    (transpiler-obfuscate-symbol *js-transpiler* name)
    `(%setq ,name  ,val)))

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
		   (or (keywordp (first x))
			   (stringp (first x))))
	  `(make-hash-table ,@x)
	  `(%new ,(first x)
			 ,@(if (transpiler-function-arguments? *js-transpiler* (first x))
			       (argument-expand-compiled-values
				       (first x)
				       (transpiler-function-arguments *js-transpiler* (first x))
				       (cdr x))
				   (cdr x)))))

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
