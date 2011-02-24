;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun c-codegen-function-prologue-for-local-variables (fi num-vars)
  `(,@(c-line "treptr __ret")
    ,@(when (< 1 num-vars)
	   `(("int __c; for (__c = " ,num-vars "; __c > 0; __c--)")))
    ,@(c-line "    *--trestack_ptr = treptr_nil")
	,@(when (transpiler-stack-locals? *current-transpiler*)
		(mapcar (fn
				  (when (eq (place-assign (place-expand-0 fi _)) _)
					(print '===========================)
					(print _)
					(print-funinfo fi))
				  `(%setq ,(place-assign (place-expand-0 fi _))
						    ,_))
			    (funinfo-local-args fi)))))

(define-c-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `((%setq "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(when (< 0 num-vars)
		  `(,(c-line "trestack_ptr += " num-vars)))
      (%function-return ,fi-sym))))

(define-c-macro %function-return (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    `(%transpiler-native
         ,@(c-line "return __ret"))))

(defun c-stack (x)
  `("trestack_ptr[" ,x "]"))
