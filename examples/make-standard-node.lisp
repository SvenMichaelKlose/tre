(make-js-project
  :title   "Hello World for node.js"
  :outfile "compiled/hello-world.js"
  :files   '("examples/hello-world.lisp")
  :transpiler
    (aprog1 *js-transpiler*
      (= (transpiler-configuration ! :platform) :nodejs)
      ; Gives 'var fs = require ("fs");':
      (= (transpiler-configuration ! :nodejs-requirements) '("fs"))))

(quit)
