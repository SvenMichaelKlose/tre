(= (transpiler-dump-passes? *js-transpiler*) t)
(make-project "Hello World"
              '("examples/hello-world.lisp")
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "compiled/hello-world.html" _])
(quit)
