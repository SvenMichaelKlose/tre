;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>
;;;;;
;;;;; Environment without extra GC'ed stack.

(defun c-codegen-function-prologue-for-local-variables (fi num-vars)
  `(,@(c-line "treptr _local_array = trearray_make (" num-vars ")")
    ,@(c-line "tregc_push (_local_array)")
    ,@(c-line "const treptr * _locals = (treptr *) TREATOM_DETAIL(_local_array)")
	,@(& (transpiler-stack-locals? *transpiler*)
	     (mapcar ^(%setq ,(place-assign (place-expand-0 fi _)) ,_)]
	             (funinfo-local-args fi)))))

(define-c-macro %function-epilogue (name)
  `(,@(& (< 0 (length (funinfo-vars (get-funinfo name))))
         `(,(c-line "tregc_pop ()")))
    (%function-return ,name)))

(define-c-macro %function-return (name)
  `(%transpiler-native ,@(c-line "return " (place-assign (place-expand-0 (get-funinfo name) '~%ret)))))

(defun c-stack (x)
  `("_TRELOCAL(" ,x ")"))
