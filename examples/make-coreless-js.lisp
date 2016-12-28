(make-project "Hello World compiler dumps with no core or imports"
              "examples/hello-world.lisp"
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-dump-passes? !) t)
                             (= (transpiler-import-from-host? !) nil)
                             (= (transpiler-configuration ! :exclude-core?) t))
              :emitter     [put-file "compiled/hello-world-coreless.js" _])
(quit)
