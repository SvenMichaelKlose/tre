;;;;; tré – Copyright (c) 2008-2013 Sven Michael Klose <pixel@copei.de>

(defun c-codegen-function-prologue-for-local-variables (fi)
  `(,@(c-line "treptr __ret")
    ,@(alet (length (funinfo-vars fi))
        `(,@(& (< 1 !)
	           `(("    int __c; for (__c = " ,! "; __c > 0; __c--)")))
          ,@(& (< 0 !)
               (c-line " *--trestack_ptr = treptr_nil"))))
    ,@(copy-arguments-to-vars fi)))

(define-c-macro %function-epilogue (name)
  (let fi (get-funinfo name)
    `((%setq "__ret" ,(place-assign (place-expand-0 fi '~%ret)))
      ,@(alet (length (funinfo-vars fi))
          (& (< 0 !)
             `(,(c-line "trestack_ptr += " !))))
      (%function-return ,name))))

(define-c-macro %function-return (name)
  `(%%native ,@(c-line "return __ret")))

(defun c-stack (x)
  `("trestack_ptr[" ,x "]"))
