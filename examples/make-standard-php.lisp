(make-project "Hello World for PHP"
              "examples/hello-world.lisp"
              :transpiler  *php-transpiler*
              :emitter     [put-file "compiled/hello-world.php" _])
(quit)
