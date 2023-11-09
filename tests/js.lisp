(= *have-environment-tests* t)

(unix-sh-mkdir "compiled" :parents t)
(make-project
      "tré JavaScript target test"
      `((toplevel . ((environment-tests)
                     (late-print (function-body #'butlast)))))
      :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                     (= (transpiler-configuration ! :save-sources?) nil))
      :emitter     [(make-html-script "compiled/test.html" _)
                    (put-file "compiled/test.js" _)])

(quit)
