;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(= *have-compiler?* t)
(= *have-c-compiler?* nil)

(unix-sh-mkdir "compiled")
(make-project "tré web console"
              `(,@(filter [+ "environment/platforms/shared/" _]
                          '("continued.lisp"

                            "url/file.lisp"
                            "url/path-pathlist.lisp"
                            "url/path-parent.lisp"
                            "url/path-suffix.lisp"
                            "url/pathname-filename.lisp"
                            "url/unix-path.lisp"
                            "url/url-path.lisp"
                            "url/url-with-new-filename.lisp"
                            "url/path-append.lisp"))

                ,@(filter [+ "environment/platforms/js/" _]
                          '("date.lisp"
                            "log.lisp"
                            "wait.lisp"
                            "slot-utils.lisp"))

                ,@(filter [+ "environment/platforms/js/dom/" _]
                          '("get/def-aos.lisp"
                            "iteration.lisp"
                            "objects/native-symbols.lisp"
                            "objects/node-predicates.lisp"
                            "objects/visible-node.lisp"
                            "objects/text-node.lisp"
                            "objects/element.lisp"
                            "objects/get-elements-by-class-name.lisp"
                            "objects/extend.lisp"
                            "get/get.lisp"
                            "get/define-element-getters.lisp"
                            "get/document-ordered.lisp"
                            "get/first-by.lisp"
                            "get/last-by.lisp"
                            "get/page-has-some-of.lisp"
                            "name.lisp"
                            "form/predicates.lisp"
                            "form/get.lisp"
                            "form/set.lisp"
                            "form/element-value.lisp"
                            "form/submit-button.lisp"
                            "table/table.lisp"
                            "table/header.lisp"
                            "move/move-children-and-remove.lisp"
                            "move/move-element-list.lisp"
                            "viewport.lisp"
                            "ready.lisp"))

                ,@(filter [+ "environment/platforms/js/event/" _]
                          '("log.lisp"
                            "native-symbols.lisp"
                            "native.lisp"
                            "event.lisp"
                            "handler.lisp"
                            "module.lisp"
                            "hook-methods.lisp"
                            "manager.lisp"
                            "utils.lisp"
                            "bind-event-methods.lisp"
                            "keycodes.lisp"))

                (toplevel . ((document-extend)
                             (event-manager.init-document document)
                             (event-manager.set-send-natively-by-default? document t)
                             (format t "Welcome to tr&eacute;, revision ~A. Copyright (c) 2005-2013 Sven Michael Klose &lt;pixel@copei.de&gt;~%" *tre-revision*))))
              :transpiler  *js-transpiler*
              :emitter     [make-html-script "compiled/webconsole.html" _])
(quit)
