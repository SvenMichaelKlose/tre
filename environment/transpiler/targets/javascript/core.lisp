(var *js-core-path* "environment/transpiler/targets/javascript/core/")

(fn js-load-core (dir-path &rest files)
  (*> #'+ (@ [!= (+ *js-core-path* dir-path _)
               (print-definition `(js-load-core ,!))
               (read-file !)
               (fetch-file !)]
             files)))

(var *js-core0* ,(js-load-core "" "return-value.lisp"))
(var *js-core*
    ,(js-load-core ""
                   "cons.lisp"
                   "defined-functions.lisp"
                   "%princ.lisp"
                   "%write-char.lisp"
                   "symbol.lisp"
                   "object-alist.lisp"))

(var *js-core-debug-print* ,(js-load-core "" "debug-print.lisp"))

(var *js-core1*
    ,(+ (js-load-core "../../../environment/"
                      "not.lisp")
        (js-load-core ""
                      "macro.lisp"
                      "eq.lisp"
                      "array.lisp"
                      "character.lisp"
                      "number.lisp"
                      "../../../environment/number.lisp"
                      "../../../environment/number-typing.lisp"
                      "apply.lisp"
                      "atom.lisp")
        (js-load-core "../../../environment/"
                      "string.lisp")))

(+! *js-core1* ,(js-load-core ""
                              "bind.lisp"
                              "../../../environment/eq.lisp"
                              "../../../environment/equality.lisp"
                              "late-cons.lisp"
                              "late-symbol.lisp"
                              "../../../environment/make-array.lisp"
                              "sequence.lisp"
                              "../../../environment/list-string.lisp"
                              "string.lisp"
                              "hash.lisp"
                              "base64.lisp"
                              "function-source.lisp"
                              "dot-expand.lisp"
                              "math.lisp"
                              "milliseconds-since-1970.lisp"
                              "keys.lisp"
                              "file.lisp"
                              "env.lisp"
                              "../../../environment/files-unsupported.lisp"))

(when *have-compiler?*
  (+! *js-core1* ,(js-load-core "" "native-eval.lisp")))

(+! *js-core1* ,(js-load-core "" "../../../environment/setf-function-p.lisp"))

(fn js-core-stream ()
  (+ ,(js-load-core "" "break.lisp")
     ,(js-load-core "" "../../../../stage3/stream.lisp")
     ,(js-load-core "" "standard-stream.lisp")
     ,(js-load-core "" "../../../environment/print.lisp")))

(fn js-core-nodejs ()
  ,(+ (js-load-core "node.js/"
                    "arguments.lisp"
                    "file.lisp")))

(var *js-core-eval* ,(js-load-core "" "eval.lisp"))
