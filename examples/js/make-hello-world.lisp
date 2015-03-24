(make-project "Hello World"
              '("examples/js/hello-world.lisp")
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "examples/js/hello-world.html" _])
(quit)
