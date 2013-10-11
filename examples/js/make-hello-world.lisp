(with-open-file out (open "examples/js/hello-world.js" :direction 'output)
  (make-project "Hello World"
                '("examples/js/hello-world.lisp")
                :transpiler  *js-transpiler*
                :emitter     [princ _ out]))
