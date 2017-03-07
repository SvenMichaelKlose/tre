(defvar *js-core-path* "environment/transpiler/targets/javascript/core/")

(fn js-load-core (dir-path &rest files)
  (apply #'+ (@ [alet (+ *js-core-path* dir-path _)
                  (print-definition `(js-load-core ,!))
                  (load-file !)
  			      (fetch-file !)]
		        files)))

(defvar *js-core0* ,(js-load-core "" "return-value.lisp"))
(defvar *js-core*
    ,(js-load-core ""
                   "cons.lisp"
                   "defined-functions.lisp"
                   "%princ.lisp"
                   "%write-char.lisp"
                   "symbol.lisp"
                   "property-list.lisp"))

(defvar *js-core-debug-print* ,(js-load-core "" "debug-print.lisp"))

(defvar *js-core1*
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
			          "atom.lisp"
                      "string.lisp")
		(js-load-core ""
                      "predefined-symbols.lisp")))

(= *js-core1* (+ *js-core1*
	             ,(js-load-core ""
		                        "bind.lisp"
		                        "../../../environment/eq.lisp"
		                        "../../../environment/equality.lisp"
		                        "late-cons.lisp"
		                        "late-symbol.lisp"
		                        "../../../environment/list.lisp"
		                        "../../../environment/append.lisp"
		                        "../../../environment/sequence.lisp"
		                        "sequence.lisp"
		                        "../../../environment/list-string.lisp"
		                        "string.lisp"
		                        "hash.lisp"
                                "base64.lisp"
                                "function-source.lisp"
                                "dot-expand.lisp"
                                "math.lisp"
                                "nanotime.lisp"
                                "property.lisp")))

(when *have-compiler?*
  (= *js-core1* (+ *js-core1* ,(js-load-core "" "native-eval.lisp"))))

(= *js-core1* (+ *js-core1* ,(js-load-core "" "../../../environment/setf-function-p.lisp")))

(fn js-core-stream ()
  (+ ,(js-load-core "" "error.lisp")
     ,(js-load-core "" "../../../../stage3/stream.lisp")
     (& (eq :browser (configuration :platform))
        ,(js-load-core "" "%force-output.lisp"))
     ,(js-load-core "" "standard-stream.lisp")
     ,(js-load-core "" "../../../environment/print.lisp")))

(fn js-core-nodejs ()
  ,(js-load-core "node.js/" "file.lisp"))

(defvar *js-core-eval* ,(js-load-core "" "eval.lisp"))
