; tré – Copyright (c) 2014,2016 Sven Michael Klose <pixel@copei.de>

(load "environment/platforms/shared/lml.lisp")
(load "environment/platforms/shared/lml2xml.lisp")
(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")
(load "environment/platforms/js/event/names.lisp")

(defvar *log-events?* nil)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré debugger"
              (+ '("environment/platforms/shared/lml2dom.lisp")
                 (list+ "environment/platforms/js/dom/"
                        '("def-aos.lisp"
                          "do.lisp"
                          "objects/native-symbols.lisp"
                          "objects/node-predicates.lisp"
                          "objects/visible-node.lisp"
                          "objects/text-node.lisp"
                          "objects/element.lisp"
                          "objects/extend.lisp"
                          "get.lisp"))
                 (list+ "environment/platforms/js/event/"
                        '("log.lisp"
                          "native-symbols.lisp"
                          "native.lisp"
                          "event.lisp"
                          "handler.lisp"
                          "module.lisp"
                          "names.lisp"
                          "manager.lisp"
                          "utils.lisp"
                          "bind-event-methods.lisp"
                          "keycodes.lisp"))
                 (list+ "environment/transpiler/"
                        '("lib/funinfo/funinfo.lisp"))
                 (list+ "environment/debugger/"
                        '("scope.lisp"
                          "window.lisp"
                          "toplevel.lisp")))
              :transpiler *js-transpiler*
              :emitter     [make-html-script "compiled/debugger.html" _])
(quit)
