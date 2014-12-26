; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun cl-packages ()
  `((defpackage :tre-core
      ((:use :common-lisp)
      (:export :nil :t :setq :labels
               ,@(make-keywords (+ (carlist +cl-renamed-imports+)
                                   *cl-builtins*)))))
    (defpackage :tre
      ((:use :tre-core)))))

(defun cl-wrappers ()
  (filter [`(defun ,_. (&rest x)
              (apply #',(make-symbol (symbol-name ._.) "COMMON-LISP") x))]
          +cl-renamed-imports+))

(alet (copy-transpiler *cl-transpiler*)
  (= (transpiler-save-sources? !) nil)
  (with-output-file o "tre.lisp"
    (filter [late-print _ o]
            (compile-sections (list (. 'core (+ (cl-packages)
                                                *cl-base*
                                                (cl-wrappers))))
                              :transpiler !))))

(quit)
