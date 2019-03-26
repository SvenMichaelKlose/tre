; tré – Copyright (c) 2011–2015 Sven Michael Klose <pixel@copei.de>

(= *gensym-prefix* "~jsG")

(unless (eq '*native-eval-return-value* *native-eval-return-value*)
  (defvar *native-eval-return-value* nil))

(defvar *js-eval-transpiler* nil)

(defun make-js-eval-transpiler ()
  (let tr (copy-transpiler *js-transpiler*)
    (transpiler-reset tr)
    (= (transpiler-only-environment-macros? tr) nil)
    (@ (i *functions*)
      (let-when f (symbol-function i.)
        (transpiler-add-defined-function tr i (car f.__source) (cdr f.__source))))
    (= *js-eval-transpiler* tr)))

(defun js-eval-transpile (tr expression)
  (clr (transpiler-cached-frontend-sections tr)
       (transpiler-cached-output-sections tr)
       (transpiler-raw-decls tr))
  (compile expression :transpiler tr))

(defun eval-compile (x)
  (with-temporary *js-transpiler* (| *js-eval-transpiler* (make-js-eval-transpiler))
    (alet *js-transpiler*
      (with-temporary (transpiler-dump-passes? !) nil
        (+ (js-eval-transpile ! x)
           (obfuscated-identifier '*native-eval-return-value*)
           " = "
           (obfuscated-identifier '~%ret)
           ";")))))

(defun eval (x)
  (%%%eval (eval-compile x))
  *native-eval-return-value*)
