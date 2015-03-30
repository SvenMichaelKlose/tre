; tré – Copyright (c) 2008,2011–2015 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)
;(= (transpiler-dump-passes? *js-transpiler*) t)

(unix-sh-mkdir "compiled" :parents t)
(make-project
      "tré JavaScript target test"
      `((toplevel . ((environment-tests))))
      :transpiler  *js-transpiler*
      :emitter     [(make-html-script "compiled/test.html" _)
                    (put-file "compiled/test.js" _)])

(quit)
