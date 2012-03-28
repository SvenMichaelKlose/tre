;;;;; tré - Copyright (c) 2011-2012 Sven Michael Klose <pixel@copei.de>

(setf *gensym-prefix* "~jsG")

(unless (eq '*native-eval-return-value* *native-eval-return-value*)
  (defvar *native-eval-return-value* nil))

(defvar *js-eval-transpiler* nil)

(defun make-js-eval-transpiler ()
  (let tr (copy-transpiler *js-transpiler*)
    (transpiler-reset tr)
    (dolist (i *defined-functions*)
      (let-when f (symbol-function i)
        (transpiler-add-defined-function tr i)
        (transpiler-add-function-args tr i (car f.__source)) ; XXX dot notation!
        (transpiler-add-function-body tr i (cdr f.__source))))
    (setf *js-eval-transpiler* tr)))

(defun js-eval-transpile (tr expression)
  (clr (transpiler-sightened-files tr)
       (transpiler-compiled-files tr)
       (transpiler-raw-decls tr))
  (concat-stringtree (js-transpile-pre tr)
   	                 (target-transpile tr :files-after-deps (list (cons 'eval (list expression)))
	 	                                  :dep-gen #'(())
		                                  :decl-gen (js-make-decl-gen tr))
   	                 (js-transpile-post)))

(defun eval (x)
  (with-temporary *js-transpiler* (or *js-eval-transpiler* (make-js-eval-transpiler))
    (let tr *js-transpiler*
      (%%%eval (+ (js-eval-transpile tr x)
                  (transpiler-obfuscated-symbol-string tr '*native-eval-return-value*)
                  " = "
                  (transpiler-obfuscated-symbol-string tr '~%ret)
                  ";"))
      *native-eval-return-value*)))
