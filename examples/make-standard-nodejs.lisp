(make-project "Hello World for node.js"
              "examples/hello-world.lisp"
              :transpiler  (aprog1 *js-transpiler*
                             (= (transpiler-configuration ! :platform) :nodejs)
                             ; Gives 'var fs = require ("fs");':
                             (= (transpiler-configuration ! :nodejs-requirements) '("fs")))
              :emitter     [put-file "compiled/hello-world.js" _])
(quit)
