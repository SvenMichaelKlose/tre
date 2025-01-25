(= (transpiler-configuration *js-transpiler* :environment) :nodejs)
(make-project
    :name        "tré web console"
    :transpiler  *js-transpiler*
    :emitter     [put-file "compiled/nodecat.js" _]
    :sections    `((toplevel . ((princ (fetch-file "make.sh"))))))
(quit)
