(load (+ *modules-path* "php/make-php-project.lisp"))

(make-php-project
  :title
    "PHP server"
  :outfile
    "compiled/server.php"
  :files
    `("server-api.lisp"
      "server/toplevel.lisp"))
(quit)
