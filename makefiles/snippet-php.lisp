(unix-sh-mkdir "compiled" :parents t)
(make-project "tré PHP back end snippet for testing"
              `((toplevel . ((print 'add-your-test-here))))
              :transpiler  (aprog1 (copy-transpiler *php-transpiler*)
                             (= (transpiler-dump-passes? !) nil) ; XXX required?
                             (= (transpiler-configuration ! :save-sources?) nil))
              :emitter     [(format t "Writing to 'compiled/snippet.php'…~F")
                            (put-file "compiled/snippet.php" _)
                            (terpri)])
(quit)
