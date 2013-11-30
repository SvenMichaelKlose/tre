;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")
(load "environment/platforms/js/event/names.lisp")

(= *have-compiler?* t)
(= *have-c-compiler?* nil)

(unix-sh-mkdir "compiled")
(make-project "tré web console"
              `(,@(list+ "environment/platforms/shared/"
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

                ,@(list+ "environment/platforms/js/"
                         '("date.lisp"
                           "log.lisp"
                           "wait.lisp"))

                ,@(list+ "environment/platforms/js/dom/"
                         '("def-aos.lisp"
                           "do.lisp"
                           "objects/native-symbols.lisp"
                           "objects/node-predicates.lisp"
                           "objects/visible-node.lisp"
                           "objects/text-node.lisp"
                           "objects/element.lisp"
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
                           "hook-methods.lisp"
                           "names.lisp"
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
