(unix-sh-mkdir "compiled" :parents t)

(make-project "tré JavaScript target test"
  (list "environment/stage3/type.lisp"
        (. 'tests (make-environment-tests))
        (. 'toplevel '((environment-tests))))
  :transpiler  (copy-transpiler *js-transpiler*)
  :emitter     [(make-html-script "compiled/test.html" _)
                (put-file "compiled/test.js" _)])

(make-project "JavaScript test unit 1"
  `("tests/unit-1.lisp")
  :transpiler  (copy-transpiler *js-transpiler*)
  :emitter     [put-file "compiled/unit-1.js" _])

(make-project "JavaScript test unit 2"
  `("tests/unit-2-getter.lisp")
  :transpiler  (copy-transpiler *js-transpiler*)
  :emitter     [put-file "compiled/unit-2-getter.js" _])

(make-project "JavaScript test unit 2"
  `("tests/unit-3-base64.lisp")
  :transpiler  (copy-transpiler *js-transpiler*)
  :emitter     [put-file "compiled/unit-3-base64.js" _])

(quit)
