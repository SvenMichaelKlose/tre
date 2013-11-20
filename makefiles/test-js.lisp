;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)
(= *transpiler-assert* t)
(= *show-definitions* t)

(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(make-project
      "tré JavaScript target test"
      `((toplevel . ((environment-tests))))
      :transpiler *js-transpiler*
      :emitter     [make-html-script "compiled/test.html" _])

(quit)
