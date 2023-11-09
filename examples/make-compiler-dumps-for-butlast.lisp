(make-js-project
  :title
    "Hello World"
  :outfile
    "compiled/hello-world.html"
  :files
    '("examples/hello-world.lisp")
  :transpiler
    (aprog1 *js-transpiler*
      (= (transpiler-dump-selector !) '(function butlast))))
(quit)
