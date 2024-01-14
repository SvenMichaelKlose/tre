(var *available-languages* '(en de))
(var *fallback-language* 'en)
(var *development-version?* t)

(load (+ *modules-path* "js/event/names.lisp"))
(load (+ *modules-path* "l10n/compile-time.lisp"))

(fn make-js-project (&key outfile title files
                          (copyright-title nil)
                          (files-before-modules nil)
                          (internal-stylesheet nil)
                          (external-stylesheets nil)
                          (transpiler nil)
                          (section-list-gen nil)
                          (sections-to-update nil))
  (make-project title
    `(,@files-before-modules
       ,(+ *modules-path* "shared/continued.lisp")
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
                 "event.lisp"
                 ,@(list+ "store/"
                          `("store.lisp"
                            "attribute.lisp"))
                 "container.lisp"
                 "schema.lisp"
                 "i18n.lisp"
                 "autoform.lisp"
                 "widgets.lisp"
;                 "widgets-editable.lisp"
                 "toplevel.lisp"))
      ,@(list+ (+ *modules-path* "sql-clause/")
               '("create-table.lisp"
                 "delete.lisp"
                 "insert.lisp"
                 "selection-info.lisp"
                 "select.lisp"
                 "update.lisp"
                 "utils-querystring.lisp"))
      ,(+ *modules-path* "js-http-request/main.lisp")
      ,@(list+ (+ *modules-path* "http-funcall/")
               '("shared/expr2dom.lisp"
                 "js/toplevel.lisp"))
      ,@files)
    :transpiler         (| transpiler
                           (copy-transpiler *js-transpiler*))
    :section-list-gen   section-list-gen
    :sections-to-update sections-to-update
    :emitter     [make-html-script outfile _
                                   :copyright-title      copyright-title
                                   :internal-stylesheet  internal-stylesheet
                                   :external-stylesheets external-stylesheets
                                   :title title]))
