(load (+ *modules-path* "/js/make-js-project.lisp"))
(make-js-project
  :title
    "Hello World compiler dumps with no core or imports"
  :outfile
    "compiled/hello-world-coreless.js"
  :files
    '("examples/hello-world.lisp")
  :transpiler
    (aprog1 (copy-transpiler *js-transpiler*)
      (= (transpiler-dump-passes? !) t)
      (= (transpiler-import-from-host? !) nil)
      (= (transpiler-configuration ! :exclude-core?) t)))
(quit)
