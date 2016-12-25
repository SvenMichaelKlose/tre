(= (transpiler-dump-passes? *js-transpiler*) nil)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré JavaScript back end snippet for testing"
              `((toplevel . ((print 'add-your-test-here))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) nil))
              :emitter     [(format t "Writing to 'compiled/snippet.html'…~F")
                            (make-html-script "compiled/snippet.html" _)
                            (terpri)])
(quit)
