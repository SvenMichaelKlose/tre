(defvar *php-core-path* "environment/transpiler/targets/php/core/")

(defvar *php-core-native*
        ,(apply #'+ (@ [fetch-file (+ "environment/transpiler/targets/php/core/native/" _ ".php")]
                       '("settings"
                         "error"
                         "character"
                         "cons"
                         "lexical"
                         "closure"
                         "symbol"
                         "array"))))

(defun php-print-native-core (out)
  (princ *php-core-native* out))

(defun php-load-core (dir-path &rest files)
  (with-temporary *have-compiler?* nil
    (apply #'+ (@ [alet (+ *php-core-path* dir-path _)
                    (print-definition  `(php-load-core ,!))
                    (load-file !)
                    (fetch-file !)]
                  files))))

(defvar *php-core0*
	,(php-load-core ""
                    "assert.lisp"
                    "return-value.lisp"
                    "superglobals.lisp"))

(defvar *php-core*
	,(php-load-core ""
                    "cons.lisp"
                    "symbol.lisp"))

(defvar *php-core2*
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
                       "not.lisp"
                       "atom.lisp"
                       "exception.lisp")
        (php-load-core ""
                       "character.lisp"
                       "eq.lisp"
                       "../../../environment/equality.lisp"
                       "error.lisp"
                       "late-cons.lisp"
                       "late-symbol.lisp"
                       "../../../environment/list.lisp"
                       "../../../environment/append.lisp"
                       "number.lisp"
                       "../../../environment/number.lisp"
                       "sequence.lisp"
                       "../../../environment/sequence.lisp"
                       "standard-stream.lisp"
                       "stream.lisp"
                       "../../../environment/print.lisp"
                       "../../../environment/list-string.lisp"
                       "string.lisp"
                       "base64.lisp"
                       "quit.lisp")
        (php-load-core "../../../environment/"
                       "string.lisp")))
