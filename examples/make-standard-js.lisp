(load (+ *modules-path* "/js/make-js-project.lisp"))
(make-js-project
  :title    "Hello World for JavaScript in browsers"
  :outfile  "compiled/hello-world.html"
  :files    '("examples/hello-world.lisp"))
(quit)
