;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun php-load-base (dir-path &rest files)
  (with-temporary *have-compiler?* nil
    (mapcan [let f (+ dir-path _)
              (format t  "(php-load-base \"~A\")~%" f)
              (read-file-all f)]
            files)))

(defvar *php-env-path* "environment/transpiler/targets/php/environment/")

(defvar *php-base*
	,(list 'quote (append (php-load-base *php-env-path*
		                      "assert.lisp"
		                      "return-value.lisp"
		                      "not.lisp"
		                      "cons.lisp"
		                      "symbol.lisp"))))

(defvar *php-base2*
	,(list 'quote (append
		              (php-load-base *php-env-path*
			              "../../../environment/number-typing.lisp"
			              "print-object.lisp"
			              "log.lisp"
			              "apply.lisp"
			              "array.lisp"
			              "atom.lisp")
		              (php-load-base "environment/transpiler/environment/"
			              "atom.lisp")
		              (php-load-base *php-env-path*
			              "bind.lisp"
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
			              "../../../environment/character.lisp"
			              "standard-stream.lisp"
			              "stream.lisp"
			              "../../../environment/print.lisp"
			              "../../../environment/list-string.lisp"
			              "string.lisp"
			              "../../../environment/member.lisp"
			              "hash.lisp"
                          "base64.lisp"
                          "quit.lisp")
		              (php-load-base "environment/transpiler/environment/"
			              "assoc.lisp"))))
