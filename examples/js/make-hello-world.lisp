(with-open-file out (open "examples/js/hello-world.js" :direction 'output)
  (make-project "Hello World"
                :files '("examples/js/hello-world.lisp")
                :target 'js
                :emitter [princ _ out]))
