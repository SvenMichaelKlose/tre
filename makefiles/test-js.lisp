;;;;; tré – Copyright (c) 2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(= *have-environment-tests* t)
(= *transpiler-assert* t)
(= *show-definitions* t)

(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(make-project
      "tré JavaScript target test"
      `(,@(filter [+ "environment/platforms/js/" _]
                  '("wait.lisp"
                    "slot-utils.lisp"

                    "dom/iteration.lisp"
                    "dom/objects/extend.lisp"
                    "dom/objects/node-predicates.lisp"
                    "dom/objects/visible-node.lisp"
                    "dom/objects/element.lisp"
                    "dom/objects/text-node.lisp"))
        (toplevel . ((environment-tests))))
      :transpiler *js-transpiler*
      :emitter     [make-html-script "compiled/test.html" _])

(quit)
