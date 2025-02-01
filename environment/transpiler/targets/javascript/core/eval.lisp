(unless (eq '*native-eval-return-value* *native-eval-return-value*)
  (var *native-eval-return-value* nil))

(var *js-eval-transpiler* nil)

(fn make-js-eval-transpiler ()
  (let tr (copy-transpiler *js-transpiler*)
    (@ (i *functions*)
      (let-when f (symbol-function i.)
        (transpiler-add-defined-function tr i (car f.__source) (cdr f.__source))))
    (= *js-eval-transpiler* tr)))

(fn js-eval-transpile (tr expression)
  (clr (transpiler-compiled-inits tr))
  (compile expression :transpiler tr))

(fn eval-compile (x)
  (with-temporary *js-transpiler* (| *js-eval-transpiler* (make-js-eval-transpiler))
    (!= *js-transpiler*
      (+ (js-eval-transpile ! x)
         (convert-identifier '*native-eval-return-value*)
         " = "
         (convert-identifier ,(list 'quote *return-symbol*))
         ";"))))

(fn eval (x)
  (%eval (eval-compile x))
  *native-eval-return-value*)
