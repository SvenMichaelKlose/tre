(make-project "Hello World"
              "examples/hello-world.lisp"
              :transpiler  (aprog1 *js-transpiler*
                             (= (transpiler-dump-passes? !) t))
              :emitter     [make-html-script "compiled/hello-world.html" _])
(quit)
