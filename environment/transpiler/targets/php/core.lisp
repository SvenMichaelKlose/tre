; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defvar *php-core-path* "environment/transpiler/targets/php/core/")

(defun php-load-base (dir-path &rest files)
  (with-temporary *have-compiler?* nil
    (mapcan [alet (+ *php-core-path* dir-path _)
              (format t  "(php-load-base \"~A\")~%" !)
              (read-file !)]
            files)))

(defvar *php-core0*
	,(list 'quote (php-load-base ""
                                 "assert.lisp"
                                 "return-value.lisp"
                                 "superglobals.lisp")))
(defvar *php-core*
	,(list 'quote (php-load-base ""
                                 "cons.lisp"
                                 "symbol.lisp")))

(defvar *php-core2*
	,(list 'quote (+ (php-load-base ""
                                    "../../../environment/number-typing.lisp"
                                    "print-object.lisp"
                                    "%princ.lisp"
                                    "apply.lisp"
                                    "hash.lisp"
                                    "array.lisp"
                                    "function.lisp"
                                    "objectp.lisp")
                     (php-load-base "../../../environment/"
                                    "not.lisp"
                                    "atom.lisp"
                                    "exception.lisp"
                                    "cps-exceptions.lisp")
                     (php-load-base ""
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
                     (php-load-base "../../../environment/"
                                    "string.lisp"))))
