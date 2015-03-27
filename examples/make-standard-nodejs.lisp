(make-project "Hello World for node.js"
              '("examples/hello-world.lisp")
              :transpiler  (aprog1 *js-transpiler*
                             (= (transpiler-configuration ! :platform) :nodejs))
              :emitter     [put-file "compiled/hello-world.js" _])
(quit)
