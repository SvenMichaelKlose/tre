(= (transpiler-configuration *js-transpiler* :environment) :nodejs)
(make-project "tré web console"
              `((toplevel . ((princ (fetch-file "make.sh")))))
              :transpiler  *js-transpiler*
              :emitter     [put-file "compiled/nodecat.js" _])
(quit)
