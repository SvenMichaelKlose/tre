;;;;; tré – Copyright (c) 2008–2011 Sven Michael Klose <pixel@copei.de>

(defun bc-codegen-function-prologue-for-local-variables (fi num-vars)
  `((%%%num-vars ,num-vars)
    ,@(codegen-copy-arguments-to-locals fi)))

(define-bc-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `((%setq "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(when (< 0 num-vars)
		  `(,(bc-line "trestack_ptr += " num-vars)))
      (%function-return ,fi-sym))))

(define-bc-macro %function-return (fi-sym)
  `(%transpiler-native ,@(bc-line "return __ret"))))

(defun bc-stack (x)
  `("trestack_ptr[" ,x "]"))
