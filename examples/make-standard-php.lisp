(make-project "Hello World"
              '("examples/hello-world.lisp")
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/hello-world.php" _])
(quit)
