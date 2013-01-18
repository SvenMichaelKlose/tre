;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Functions with purely malloc'ed GC.

(defun c-codegen-function-prologue-for-local-variables (fi num-vars)
  `(,@(c-line "treptr _local_array = trearray_make (" num-vars ")")
    ,@(c-line "tregc_push (_local_array)")
    ,@(c-line "const treptr * _locals = (treptr *) TREATOM_DETAIL(_local_array)")
	,@(& (transpiler-stack-locals? *current-transpiler*)
	     (mapcar ^(%setq ,(place-assign (place-expand-0 fi _)) ,_)]
	             (funinfo-local-args fi)))))

(define-c-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-vars fi)))
    `(,@(& (< 0 num-vars)
	  	   `(,(c-line "tregc_pop ()")))
      (%function-return ,fi-sym))))

(define-c-macro %function-return (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    `(%transpiler-native
         ,@(c-line "return " (place-assign (place-expand-0 fi '~%ret))))))

(defun c-stack (x)
  `("_TRELOCAL(" ,x ")"))
