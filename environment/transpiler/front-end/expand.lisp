;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun make-overlayed-std-macro-expander (tr expander-name)
  (with (e       (define-expander expander-name)
         mypred  (expander-pred e)
		 mycall  (expander-call e))
    (= (expander-pred e) (lx (tr mypred)
						   (fn | (funcall ,mypred _)
                                 (? (transpiler-only-environment-macros? ,tr)
				 		            (%%env-macrop _)
				 		            (%%macrop _))))
   		  (expander-call e) (lx (tr mypred mycall)
								(fn ? (funcall ,mypred _) (funcall ,mycall _)
                                      (transpiler-only-environment-macros? ,tr) (%%env-macrocall _)
                                      (%%macrocall _))))))

(defun transpiler-make-std-macro-expander (tr)
  (let expander-name ($ (transpiler-name tr) '-standard)
    (= (transpiler-std-macro-expander tr) expander-name)
    (make-overlayed-std-macro-expander tr expander-name)))

(defmacro define-transpiler-std-macro (tr name &rest args-and-body)
  (print-definition `(define-transpiler-std-macro ,tr ,name ,args-and-body.))
  `(progn
     (transpiler-add-inline-exception ,tr ',name)
     (define-expander-macro ,(transpiler-std-macro-expander (eval tr)) ,name ,@args-and-body)))

(defun transpiler-macroexpand (tr x)
  (with-temporary *=-function?* (transpiler-=-function? tr)
    (expander-expand (transpiler-std-macro-expander ,tr) x)))

(defmacro transpiler-wrap-invariant-to-binary (definer op len replacement combinator)
  `(,definer ,op (&rest x)
     (transpiler-add-inline-exception *current-transpiler* ,(list 'quote replacement))
     (? (< ,len (length x))
        (cons ',combinator (mapcar (fn `(,replacement ,,@(subseq x 0 ,(1- len)) ,,_)) (subseq x ,(1- len))))
        (cons ',replacement x))))
