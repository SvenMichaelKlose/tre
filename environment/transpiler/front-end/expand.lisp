;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun transpiler-macro? (tr name)
  (or (expander-has-macro? (transpiler-std-macro-expander tr) name)
	  (expander-has-macro? (transpiler-macro-expander tr) name)))

(defmacro define-transpiler-std-macro (tr name &rest args-and-body)
  (let quoted-name (list 'quote name)
    `(progn
       (when (expander-has-macro? (transpiler-std-macro-expander ,tr) ,quoted-name)
	     (warn "Macro ~A is already defined as a standard macro." ,quoted-name))
	   (when (expander-has-macro? (transpiler-macro-expander ,tr) ,quoted-name)
	     (error "Macro ~A is already defined in code generator." ,quoted-name))
	   (transpiler-add-inline-exception ,tr ,quoted-name)
       (define-expander-macro ,(transpiler-std-macro-expander (eval tr)) ,name ,@args-and-body))))

(defun transpiler-macroexpand (tr x)
  (with-temporary *setf-function?* (transpiler-setf-function? tr)
	(expander-expand (transpiler-std-macro-expander tr) x)))

(defmacro transpiler-wrap-invariant-to-binary (definer op len repl-op combiner)
  `(,definer ,op (&rest x)
     (transpiler-add-inline-exception *current-transpiler* ,(list 'quote repl-op))
     (? (< ,len (length x))
        (cons ',combiner (mapcar (fn `(,repl-op ,,@(subseq x 0 ,(1- len)) ,_)) (subseq x ,(1- len))))
        (cons ',repl-op x))))
