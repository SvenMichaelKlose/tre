(const *log-events?* nil)
(const *fallback-language* :en)
(const *available-languages* '(:en))
(const *have-lml-components?* t)

(load "tre_modules/js/event/names.lisp")
(load "tre_modules/l10n/compile-time.lisp")

(make-project "tré JavaScript only project"
    `(,@(list+ "tre_modules/l10n/"
               `("lang.lisp"
                 "l10n.lisp"))
      ,@(list+ "tre_modules/js/dom/"
               `("add-onload.lisp"
                 "browser.lisp"
                 "def-aos.lisp"
                 "detect-language.lisp"
                 "do.lisp"
                 ,@(list+ "objects/"
                          '("node-predicates.lisp"
                            "nodelist.lisp"
                            "document.lisp"
                            "visible-node.lisp"
                            "element.lisp"
                            "text-node.lisp"
                            "extend.lisp"))
                 "get.lisp"
                 "document-location.lisp"
                 "table.lisp"
                 "viewport.lisp"
                 ,@(list+ "form/"
                          '("predicates.lisp"
                            "get.lisp"
                            "select.lisp"
                            "element-value.lisp"))
                 ,@(list+ "iframe/"
                          '("iframe.lisp"
                            "make.lisp"
                            "make-with-url.lisp"
                            "copy.lisp"))
                 "window-url.lisp"))
      ,@(list+ "tre_modules/js/event/"
               '("log.lisp"
                 "names.lisp"
                 "native.lisp"
                 "event.lisp"
                 "handler.lisp"
                 "module.lisp"
                 "manager.lisp"
                 "utils.lisp"
                 "bind-event-methods.lisp"
                 "keycodes.lisp"))
      ,@(list+ "tre_modules/lml/"
               `("dom2lml.lisp"
                 "component.lisp"
                 "lml2dom.lisp"
                 "expand.lisp"
                 ,@(list+ "store/"
                          `("store.lisp"
                            "attribute.lisp"))
                 "container.lisp"
                 "autoform.lisp"
                 "autoform-widgets.lisp"))
      "tre_modules/js-http-request/main.lisp"
      "toplevel.lisp")
    :transpiler  *js-transpiler*
    :emitter     [make-html-script "compiled/index.html" _
                                   :title            "tré JavaScript only project"
                                   :copyright-title  "Copyright message missing"])
(quit)
