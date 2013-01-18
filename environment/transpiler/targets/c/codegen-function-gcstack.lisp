;;;;; tré – Copyright (c) 2008-2013 Sven Michael Klose <pixel@copei.de>

(defun c-codegen-function-prologue-for-local-variables (fi)
  `(,@(c-line "treptr __ret")
    ,@(alet (length (funinfo-vars fi))
        `(,@(& (< 1 !)
	           `(("    int __c; for (__c = " ,! "; __c > 0; __c--)")))
          ,@(& (< 0 !)
               (c-line " *--trestack_ptr = treptr_nil"))))
    ,@(codegen-copy-arguments-to-locals fi)))

(define-c-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-vars fi)))
    `((%setq "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(& (< 0 num-vars)
		  `(,(c-line "trestack_ptr += " num-vars)))
      (%function-return ,fi-sym))))

(define-c-macro %function-return (fi-sym)
  `(%transpiler-native ,@(c-line "return __ret")))

(defun c-stack (x)
  `("trestack_ptr[" ,x "]"))
