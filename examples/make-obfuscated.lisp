(transpiler-enable-pass *js-transpiler* :obfuscate)

(make-project "Hello World"
              '("examples/hello-world.lisp")
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "compiled/hello-world-obfuscated.html" _])
(quit)
