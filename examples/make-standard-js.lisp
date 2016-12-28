(make-project "Hello World for JavaScript in browsers"
              "examples/hello-world.lisp"
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "compiled/hello-world.html" _])
(quit)
