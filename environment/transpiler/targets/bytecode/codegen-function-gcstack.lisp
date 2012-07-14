;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun bc-codegen-function-prologue-for-local-variables (fi num-vars)
  `(,@(bc-line "treptr __ret")
    ,@(when (< 1 num-vars)
	   `(("    int __c; for (__c = " ,num-vars "; __c > 0; __c--)")))
    ,@(bc-line " *--trestack_ptr = treptr_nil")
	,@(when (transpiler-stack-locals? *current-transpiler*)
		(mapcar (fn
				  (when (eq (place-assign (place-expand-0 fi _)) _)
					(print '===========================)
					(print _)
					(print-funinfo fi))
				  `(%setq ,(place-assign (place-expand-0 fi _))
						    ,_))
			    (funinfo-local-args fi)))))

(define-bc-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `((%setq "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(when (< 0 num-vars)
		  `(,(bc-line "trestack_ptr += " num-vars)))
      (%function-return ,fi-sym))))

(define-bc-macro %function-return (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    `(%transpiler-native
         ,@(bc-line "return __ret"))))

(defun bc-stack (x)
  `("trestack_ptr[" ,x "]"))
