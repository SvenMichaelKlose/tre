(with-output-file out "examples/js/hello-world.js"
  (make-project "Hello World"
                '("examples/js/hello-world.lisp")
                :transpiler  *js-transpiler*
                :emitter     [princ _ out]))
(quit)
