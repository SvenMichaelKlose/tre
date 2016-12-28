(make-project "Hello World"
              "examples/hello-world.lisp"
              :transpiler  (aprog1 *js-transpiler*
                             (transpiler-enable-pass ! :obfuscate))
              :emitter     [make-html-script "compiled/hello-world-obfuscated.html" _])
(quit)
