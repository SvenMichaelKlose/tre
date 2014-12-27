; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun cl-packages ()
  `((defpackage :tre-core
      (:export :nil :t :setq :labels
                ,@(make-keywords (+ (carlist +cl-renamed-imports+)
                                    *cl-builtins*))))
    (defpackage :tre
      (:use :tre-core))))

(defun cl-symbol (x)
  (make-symbol (symbol-name x) "COMMON-LISP"))

(defun cl-wrapper (x)
  (format nil "(cl:defun ~A (cl:&rest x) (cl:apply #'cl:~A x))~%"
              (symbol-name x.) (symbol-name .x.)))

(defun cl-wrappers ()
  (filter #'cl-wrapper
          (+ (filter [list _ _] +cl-direct-imports+)
             +cl-renamed-imports+)))

(alet (copy-transpiler *cl-transpiler*)
  (= (transpiler-save-sources? !) nil)
  (with-output-file o "tre.lisp"
    (filter [late-print _ o]
            (let c (compile-sections (list (. 'core *cl-base*))
                                     :transpiler !)
              (+ (cl-packages)
                 '((in-package :tre-core))
                 c)))
    (adolist ((cl-wrappers))
      (princ ! o))))

(quit)
