(load "tre_modules/js/event/names.lisp")

(var *log-events?* nil)

(= *allow-redefinitions?* t)
(= *have-compiler?* t)

(unix-sh-mkdir "compiled" :parents t)
(make-project "tré web console"
              `(,@(list+ "tre_modules/js/"
                         '("wait.lisp"))

                ,@(list+ "tre_modules/js/dom/"
                         '("def-aos.lisp"
                           "do.lisp"
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

                ,@(list+ "tre_modules/js/event/"
                         '("native.lisp"
                           "names.lisp"
                           "utils.lisp"
                           "bind-event-methods.lisp"
                           "keycodes.lisp"))
                ,@(list+ "tre_modules/js/"
                         '("dump.lisp"))

                (toplevel . ((document-extend)
                             (*event-manager*.init-document document)
                             (*event-manager*.set-send-natively-by-default? document t)
                             (format t "Welcome to tré, revision ~A.~%" *tre-revision*))))
              :transpiler  (aprog1 (copy-transpiler *js-transpiler*)
                             (= (transpiler-configuration ! :save-sources?) t))
              :emitter     [(format t "Writing to 'compiled/webconsole.html'…~F")
                            (make-html-script "compiled/webconsole.html" _)
                            (terpri)])
(quit)
