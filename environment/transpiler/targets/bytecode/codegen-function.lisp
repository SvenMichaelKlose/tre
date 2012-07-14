;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Functions with purely malloc'ed GC.

(defun bc-codegen-function-prologue-for-local-variables (fi num-vars)
  `(,@(bc-line "treptr _local_array = trearray_make (" num-vars ")")
    ,@(bc-line "tregc_push (_local_array)")
    ,@(bc-line "const treptr * _locals = (treptr *) TREATOM_DETAIL(_local_array)")
	,@(when (transpiler-stack-locals? *current-transpiler*)
	(mapcar (fn `(%setq ,(place-assign (place-expand-0 fi _))
						    ,_))
		    (funinfo-local-args fi)))))

(define-bc-macro %function-epilogue (fi-sym)
  (with (fi (get-funinfo-by-sym fi-sym)
    	 num-vars (length (funinfo-env fi)))
    `(,@(when (< 0 num-vars)
	  	  `(,(bc-line "tregc_pop ()")))
      (%function-return ,fi-sym))))

(define-bc-macro %function-return (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    `(%transpiler-native
         ,@(bc-line "return " (place-assign (place-expand-0 fi '~%ret))))))

(defun bc-stack (x)
  `("_TRELOCAL(" ,x ")"))
