(load (+ *modules-path* "js/make-js-project.lisp"))

(make-js-project
    :title
      "tré JavaScript only project"
    :copyright-title
      "Copyright message missing"
    :outfile
      "compiled/index.html"
    :files
      `("toplevel.lisp"))
(quit)
