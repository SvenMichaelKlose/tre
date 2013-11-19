;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(load "environment/platforms/shared/html/doctypes.lisp")
(load "environment/platforms/shared/html/script.lisp")

(= *have-compiler?* t)
(= *have-c-compiler?* nil)

(defun make-site ()
  (unix-sh-mkdir "compiled")
  (make-project
      "tré web console"
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
	                "wait.lisp"
	                "slot-utils.lisp"

	                "dom/get/def-aos.lisp"
	                "dom/iteration.lisp"
	                "dom/objects/native-symbols.lisp"
	                "dom/objects/node-predicates.lisp"
	                "dom/objects/visible-node.lisp"
	                "dom/objects/text-node.lisp"
	                "dom/objects/element.lisp"
	                "dom/objects/get-elements-by-class-name.lisp"
	                "dom/objects/extend.lisp"
	                "dom/get/get.lisp"
	                "dom/get/define-element-getters.lisp"
	                "dom/get/document-ordered.lisp"
	                "dom/get/first-by.lisp"
	                "dom/get/last-by.lisp"
	                "dom/get/page-has-some-of.lisp"
	                "dom/name.lisp"
	                "dom/form/predicates.lisp"
	                "dom/form/get.lisp"
	                "dom/form/set.lisp"
	                "dom/form/element-value.lisp"
	                "dom/form/submit-button.lisp"
	                "dom/table/table.lisp"
	                "dom/table/header.lisp"
	                "dom/move/move-children-and-remove.lisp"
	                "dom/move/move-element-list.lisp"
	                "dom/viewport.lisp"
	                "dom/ready.lisp"

	                "event/log.lisp"
	                "event/native-symbols.lisp"
	                "event/native.lisp"
	                "event/event.lisp"
	                "event/handler.lisp"
	                "event/module.lisp"
	                "event/hook-methods.lisp"
	                "event/manager.lisp"
	                "event/utils.lisp"
	                "event/bind-event-methods.lisp"
	                "event/keycodes.lisp"

	                "log.lisp"))

        (toplevel . ((document-extend)
                     (event-manager.init-document document)
                     (event-manager.set-send-natively-by-default? document t)
                     (format t "Welcome to tr&eacute;, revision ~A. Copyright (c) 2005-2013 Sven Michael Klose &lt;pixel@copei.de&gt;~%" *tre-revision*))))
      :transpiler  *js-transpiler*
      :emitter     [make-html-script "compiled/webconsole.html" _]))

(make-site)
(quit)
