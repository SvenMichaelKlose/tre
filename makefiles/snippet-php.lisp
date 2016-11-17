; tré – Copyright (c) 2008–2016 Sven Michael Klose <pixel@copei.de>

(= (transpiler-dump-passes? *php-transpiler*) nil)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré PHP  back end snippet for testing"
              `("environment/stage3/print.lisp" ; TODO: Remove this workaround.
                (toplevel . ((print 'add-your-test-here))))
              :transpiler  (aprog1 (copy-transpiler *php-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) nil))
              :emitter     [(format t "Writing to 'compiled/snippet.php'…~F")
                            (put-file "compiled/snippet.php" _)
                            (terpri)])
(quit)
