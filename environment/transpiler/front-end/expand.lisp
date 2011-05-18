;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun transpiler-macro? (tr name)
  (or (expander-has-macro? (transpiler-std-macro-expander tr) name)
	  (expander-has-macro? (transpiler-macro-expander tr) name)))

(defmacro define-transpiler-std-macro (tr &rest x)
  (with (tre (eval tr)
		 name x.)
	(when (expander-has-macro? (transpiler-std-macro-expander tre) name)
	  (warn "Macro ~A already defined as a standard macro." name))
	(when (expander-has-macro? (transpiler-macro-expander tre) name)
	  (error "Macro ~A already defined in code-generator." name))
	(transpiler-add-inline-exception tre name)
    `(define-expander-macro ,(transpiler-std-macro-expander tre) ,@x)))

(defun transpiler-macroexpand (tr x)
  (with-temporary *setf-immediate-slot-value* t
    (with-temporary *setf-function?* (transpiler-setf-function? tr)
	  (expander-expand (transpiler-std-macro-expander tr) x))))

(defmacro transpiler-wrap-invariant-to-binary (definer op len repl-op combiner)
  `(,definer ,op (&rest x)
     (transpiler-add-inline-exception *current-transpiler* ,repl-op)
     (? (< ,len (length x))
        (cons ',combiner (mapcar (fn `(,repl-op ,,@(subseq x 0 ,(1- len)) ,_)) (subseq x ,(1- len))))
        (cons ',repl-op x))))
