(load "environment/platforms/js/event/names.lisp")

(var *log-events?* nil)

(= *allow-redefinitions?* t)
(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré web console"
              `(,@(list+ "environment/platforms/shared/"
                         '("continued.lisp"))

                ,@(list+ "environment/platforms/js/"
                         '("milliseconds-since-1970.lisp"
                           "wait.lisp"))

                ,@(list+ "environment/platforms/js/dom/"
                         '("def-aos.lisp"
                           "do.lisp"
                           "objects/native-symbols.lisp"
                           "objects/node-predicates.lisp"
                           "objects/visible-node.lisp"
                           "objects/text-node.lisp"
                           "objects/element.lisp"
                           "objects/document.lisp"
                           "objects/extend.lisp"
                           "get.lisp"
                           "form/predicates.lisp"
                           "form/get.lisp"
                           "form/element-value.lisp"
                           "table.lisp"
                           "viewport.lisp"))

                ,@(list+ "environment/platforms/js/event/"
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

                ,@(list+ "environment/platforms/js/"
                         '("log-message.lisp"))

                (toplevel . ((document-extend)
                             (*event-manager*.init-document document)
                             (*event-manager*.set-send-natively-by-default? document t)
                             (format t "Welcome to tr&eacute;, revision ~A.~%" *tre-revision*))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) t))
              :emitter     [(format t "Writing to 'compiled/webconsole.html'…~F")
                            (make-html-script "compiled/webconsole.html" _)
                            (terpri)])
(quit)
