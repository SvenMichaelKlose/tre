(make-project "Hello World"
              '("examples/hello-world.lisp")
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-dump-selector !) '(function butlast)))
              :emitter     [make-html-script "compiled/hello-world.html" _])
(quit)
