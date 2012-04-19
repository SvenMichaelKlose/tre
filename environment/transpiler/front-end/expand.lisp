;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun make-overlayed-std-macro-expander (expander-name)
  (with (e       (define-expander expander-name)
         mypred  (expander-pred e)
		 mycall  (expander-call e))
    (setf (expander-pred e) (lx (mypred)
								(fn or (funcall ,mypred _)
				 				       (%%macrop _)))
   		  (expander-call e) (lx (mypred mycall)
								(fn ? (funcall ,mypred _)
				 				      (funcall ,mycall _)
				 				      (%%macrocall _))))))

(defun transpiler-make-std-macro-expander (tr)
 (make-overlayed-std-macro-expander (transpiler-std-macro-expander tr)))

(defmacro define-transpiler-std-macro (tr name &rest args-and-body)
  (let quoted-name (list 'quote name)
    `(progn
       (when (expander-has-macro? (transpiler-std-macro-expander ,tr) ,quoted-name)
	     (warn "Macro ~A is already defined as a standard macro.~%" ,quoted-name))
	   (when (expander-has-macro? (transpiler-macro-expander ,tr) ,quoted-name)
	     (error "Macro ~A is already defined in code generator.~%" ,quoted-name))
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
