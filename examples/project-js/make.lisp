(const *log-events?* nil)
(const *fallback-language* :en)
(const *available-languages* '(:en))

(var *modules-path* "../../modules/")

(load (+ *modules-path* "js/event/names.lisp"))
(load (+ *modules-path* "l10n/compile-time.lisp"))

(make-project "tré JavaScript only project"
    `(,@(list+ (+ *modules-path* "l10n/")
               `("lang.lisp"
                 "l10n.lisp"))
      ,@(list+ (+ *modules-path* "js/dom/")
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
      ,@(list+ (+ *modules-path* "js/event/")
               '("names.lisp"
                 "native.lisp"
                 "utils.lisp"
                 "listener-methods.lisp"
                 "keycodes.lisp"))
      ,@(list+ (+ *modules-path* "lml/")
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
      (+ *modules-path* "js-http-request/main.lisp")
      "toplevel.lisp")
    :transpiler  *js-transpiler*
    :emitter     [make-html-script "compiled/index.html" _
                                   :title            "tré JavaScript only project"
                                   :copyright-title  "Copyright message missing"])
(quit)
