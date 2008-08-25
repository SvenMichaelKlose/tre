;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Expansion of alternative standard macros.

(defmacro define-js-std-macro (name args body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,body))

(define-js-std-macro defun (name args &rest body)
  (progn
	 (unless (in? name 'apply)
	   (acons! name args (transpiler-function-args tr)))
    `(%setq ,name
		    #'(lambda ,args
    		    ,@body))))

(define-js-std-macro defmacro (name args &rest body)
  (progn
	(eval (car (macroexpand `(define-js-std-macro ,name ,args ,@body))))
    nil))

(define-js-std-macro defvar (name val)
  `(%setq ,name  ,val))

(define-js-std-macro slot-value (x y)
  `(%slot-value ,x ,(second y)))

;; Make object if first argument is not a keyword, or string.
(define-js-std-macro new (&rest x)
  (if (and (consp x)
		   (or (keywordp (first x))
			   (stringp (first x))))
	  `(make-hash-table ,@x)
	  `(%new ,@x)))

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
