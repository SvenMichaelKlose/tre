;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun js-eval-transpile (expression)
  (with-temporary *js-transpiler* (copy-array *js-transpiler* :copy-elements? t)
    (let tr *js-transpiler*
      (transpiler-reset tr)
      (target-transpile-setup tr :obfuscate? nil)
      (dolist (i *defined-functions*)
        (let-when f (symbol-function i)
          (transpiler-add-defined-function tr i)
          (transpiler-add-function-args tr i (car f.__source))
          (transpiler-add-function-body tr i (cdr f.__source))))
	  (concat-stringtree
		  (js-transpile-pre tr)
    	  (target-transpile tr :files-after-deps (list (cons 'eval (list expression)))
		 	                   :dep-gen #'(())
			                   :decl-gen (js-make-decl-gen tr))
    	  (js-transpile-post)))))

(defun eval (x)
  (%%%eval (+ (js-eval-transpile x)
              (transpiler-obfuscated-symbol-string *js-transpiler* '*native-eval-return-value*)
              " = "
              (transpiler-obfuscated-symbol-string *js-transpiler* '~%ret)
              ";"))
  *native-eval-return-value*)
