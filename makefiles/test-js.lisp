;;;;; tré – Copyright (c) 2008,2011–2014 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)
(= *transpiler-assert* t)

(load "environment/platforms/shared/lml.lisp")
(load "environment/platforms/shared/lml2xml.lisp")
(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(unix-sh-mkdir "compiled")
(make-project
      "tré JavaScript target test"
      `((toplevel . ((environment-tests))))
      :transpiler *js-transpiler*
      :emitter     [(make-html-script "compiled/test.html" _)
                    (put-file "compiled/test.js" _)])

(quit)
