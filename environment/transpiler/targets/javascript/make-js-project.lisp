(var *fallback-language* :en)

(load (+ *modules-path* "js/event/names.lisp"))
(load (+ *modules-path* "l10n/compile-time.lisp"))

(fn make-js-project (&key outfile title files
                          (copyright nil)
                          (files-before-modules nil)
                          (internal-stylesheet nil)
                          (external-stylesheets nil)
                          (transpiler nil)
                          (emitter nil))
  (unless transpiler
    (= transpiler (copy-transpiler *js-transpiler*)))
  (let nodejs? (eq :nodejs (transpiler-configuration transpiler :platform))
    (make-project title
      `(,@files-before-modules
        ,@(unless nodejs?
            `(,(+ *modules-path* "shared/continued.lisp")
              ,@(list+ (+ *modules-path* "l10n/")
                 `("lang.lisp"
                   "l10n.lisp"))
              ,@(list+ (+ *modules-path* "js/")
                       '("dump.lisp"
                         "json.lisp"
                         "wait.lisp"
                         "unicode.lisp"
                         "unicode-utf8.lisp"))
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
                                    "extend.lisp"
                                    "query.lisp"
                                    "canvas.lisp"))
                         "get.lisp"
                         "document-location.lisp"
                         "table.lisp"
                         "viewport.lisp"
                         "window-url.lisp"))
              (+ *modules-path* "js/dump.lisp")
              ,@(list+ (+ *modules-path* "js/event/")
                       '("names.lisp"
                         "native.lisp"
                         "utils.lisp"
                         "tracking.lisp"
                         "listener-methods.lisp"
                         "keycodes.lisp"))
              ,@(list+ (+ *modules-path* "lml/")
                       `("dom2lml.lisp"
                         "component.lisp"
                         "lml2dom.lisp"
                         "expand.lisp"
                         ,@(unless nodejs?
                             '("event.lisp"))
                         ,@(list+ "store/"
                                  `("store.lisp"
                                    "attribute.lisp"))
                         "container.lisp"
                         "schema.lisp"
                         "i18n.lisp"
                         "autoform.lisp"
                         "widgets.lisp"
                         ; "widgets-editable.lisp"
                         "toplevel.lisp"))
              ,(+ *modules-path* "js-http-request/main.lisp")
              ,@(list+ (+ *modules-path* "http-funcall/")
                       '("shared/expr2dom.lisp"
                        "js/toplevel.lisp"))))
      ,@files)
    :transpiler transpiler
    :emitter
      [? nodejs?
         (put-file outfile _)
         (make-html-script outfile _
             :copyright            copyright
             :internal-stylesheet  internal-stylesheet
             :external-stylesheets external-stylesheets
             :title title)])))
