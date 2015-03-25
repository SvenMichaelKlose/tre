(= (transpiler-dump-selector *js-transpiler*) '(function butlast))

(make-project "Hello World"
              '("examples/hello-world.lisp")
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "compiled/hello-world.html" _])
(quit)
