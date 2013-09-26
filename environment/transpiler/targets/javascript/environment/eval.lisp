;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(= *gensym-prefix* "~jsG")

(unless (eq '*native-eval-return-value* *native-eval-return-value*)
  (defvar *native-eval-return-value* nil))

(defvar *js-eval-transpiler* nil)

(defun make-js-eval-transpiler ()
  (let tr (copy-transpiler *js-transpiler*)
    (transpiler-reset tr)
    (= (transpiler-only-environment-macros? tr) nil)
    (dolist (i *defined-functions*)
      (let-when f (symbol-function i)
        (transpiler-add-defined-function tr i (car f.__source) (cdr f.__source))))
    (= *js-eval-transpiler* tr)))

(defun js-eval-transpile (tr expression)
  (clr (transpiler-frontend-files tr)
       (transpiler-compiled-files tr)
       (transpiler-raw-decls tr))
  (target-transpile tr :prologue-gen     #'js-prologue
                       :epilogue-gen     #'js-epilogue
                       :files-after-deps (list (cons 'eval (list expression)))
		               :decl-gen #'js-make-decl-gen))

(defun eval-compile (x)
  (with-temporary *js-transpiler* (| *js-eval-transpiler* (make-js-eval-transpiler))
    (let tr *js-transpiler*
      (with-temporaries ((transpiler-dump-passes? tr) nil
                         (transpiler-expex-warnings? tr) nil)
        (+ (js-eval-transpile tr x)
           (obfuscated-symbol-string '*native-eval-return-value*)
           " = "
           (obfuscated-symbol-string '~%ret)
           ";")))))

(defun eval (x)
  (%%%eval (eval-compile x))
  *native-eval-return-value*)
