(unix-sh-mkdir "compiled" :parents t)

(make-project "PHP target test"
    (list "environment/stage3/type.lisp"
          (. 'tests (make-environment-tests))
          (. 'toplevel '((environment-tests))))
    :transpiler  (copy-transpiler *php-transpiler*)
    :emitter     [put-file "compiled/test.php" _])

(make-project "PHP test unit 1"
    `("tests/unit-1.lisp")
    :transpiler  (copy-transpiler *php-transpiler*)
    :emitter     [put-file "compiled/unit-1.php" _])

(make-project "PHP test unit 2"
    `("tests/unit-2-getter.lisp")
    :transpiler  (copy-transpiler *php-transpiler*)
    :emitter     [put-file "compiled/unit-2-getter.php" _])

(make-project "PHP test unit 3"
    `("tests/unit-3-base64.lisp")
    :transpiler  (copy-transpiler *php-transpiler*)
    :emitter     [put-file "compiled/unit-3-base64.php" _])

(quit)
