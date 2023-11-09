(load (+ *modules-path* "js/make-js-project.lisp"))

(make-js-project
  :title
    "tré JavaScript/PHP project"
  :copyright-title
    "Copyright message missing"
  :outfile
    "compiled/index.html"
  :files
    `("server-api.lisp"
      "client/toplevel.lisp"))
(quit)
