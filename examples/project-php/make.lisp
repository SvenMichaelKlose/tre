(load (+ *modules-path* "php/make-php-project.lisp"))

(make-php-project
  :title
    "tré PHP only project"
  :outfile
    "compiled/index.php"
  :files
    `("toplevel.lisp"))
(quit)
