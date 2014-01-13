;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(defun php-load-base (dir-path &rest files)
  (with-temporary *have-compiler?* nil
    (mapcan [alet (+ dir-path _)
              (format t  "(php-load-base \"~A\")~%" !)
              (read-file-all !)]
            files)))

(defvar *php-env-path* "environment/transpiler/targets/php/environment/")

(defvar *php-base0*
	,(list 'quote (php-load-base *php-env-path*
		              "assert.lisp"
		              "return-value.lisp"
                      "superglobals.lisp")))
(defvar *php-base*
	,(list 'quote (php-load-base *php-env-path*
		              "cons.lisp"
		              "symbol.lisp")))

(defvar *php-base2*
	,(list 'quote (+ (php-load-base *php-env-path*
			             "../../../environment/number-typing.lisp"
			             "print-object.lisp"
			             "%princ.lisp"
			             "apply.lisp"
			             "exception.lisp"
			             "hash.lisp"
			             "array.lisp"
			             "atom.lisp")
		             (php-load-base "environment/transpiler/environment/"
                         "not.lisp"
			             "atom.lisp"
                         "cps-exceptions.lisp")
		             (php-load-base *php-env-path*
			             "character.lisp"
			             "eq.lisp"
			             "../../../environment/equality.lisp"
			             "error.lisp"
			             "late-cons.lisp"
			             "late-symbol.lisp"
			             "../../../environment/list.lisp"
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
		             (php-load-base "environment/transpiler/environment/"
                         "string.lisp"))))
