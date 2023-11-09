(load (+ *modules-path* "/php/make-php-project.lisp"))
(make-php-project
  :title    "Hello World for PHP"
  :outfile  "compiled/hello-world.php"
  :files    '("examples/hello-world.lisp"))
(quit)
