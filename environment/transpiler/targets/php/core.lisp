(var *php-core-path* "environment/transpiler/targets/php/core/")

(var *php-core-native*
     ,(apply #'+ (@ [fetch-file (+ "environment/transpiler/targets/php/core/native/" _ ".php")]
                    '("remove-magic-quotes"
                      "settings"
                      "error"
                      "character"
                      "cons"
                      "lexical"
                      "closure"
                      "symbol"
                      "array"))))

(fn php-print-native-core (out)
  (princ *php-core-native* out))

(fn php-load-core (dir-path &rest files)
  (with-temporary *have-compiler?* nil
    (apply #'+ (@ [!= (+ *php-core-path* dir-path _)
                    (print-definition  `(php-load-core ,!))
                    (load-file !)
                    (fetch-file !)]
                  files))))

(var *php-core0*
    ,(php-load-core ""
                    "assert.lisp"
                    "return-value.lisp"))

(var *php-core*
    ,(php-load-core ""
                    "cons.lisp"
                    "symbol.lisp"))

(var *php-core2*
    ,(+ (php-load-core ""
                       "../../../environment/number-typing.lisp"
                       "print-object.lisp"
                       "%princ.lisp"
                       "apply.lisp"
                       "hash.lisp"
                       "array.lisp"
                       "function.lisp"
                       "objectp.lisp")
        (php-load-core "../../../environment/"
                       "not.lisp")
        (php-load-core ""
                       "character.lisp"
                       "eq.lisp"
                       "../../../environment/equality.lisp"
                       "error.lisp"
                       "late-cons.lisp"
                       "late-symbol.lisp"
                       "number.lisp"
                       "../../../environment/number.lisp"
                       "sequence.lisp"
                       "standard-stream.lisp"
                       "%force-output.lisp"
                       "../../../environment/print.lisp"
                       "../../../environment/list-string.lisp"
                       "string.lisp"
                       "property-names.lisp"
                       "../../../environment/property.lisp"
                       "../../../environment/make-object.lisp"
                       "base64.lisp"
                       "quit.lisp"
                       "math.lisp")
        (php-load-core "../../../environment/"
                       "string.lisp")))
