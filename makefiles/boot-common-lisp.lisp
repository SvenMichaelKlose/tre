; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun cl-packages ()
  `((defpackage :tre-core
      (:export :nil :t :setq :labels
                ,@(make-keywords (+ +cl-direct-imports+
                                    (carlist +cl-renamed-imports+)
                                    *cl-builtins*
                                    +cl-core-variables+))))
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
  (with-temporary *transpiler* !
    (add-defined-variable '*macros*))
  (= (transpiler-save-sources? !) nil)
  (with-output-file o "boot-common.lisp"
    (format o "(declaim #+sbcl(sb-ext:muffle-conditions compiler-note style-warning))~%")
    ; Use to debug...
    (format o "(proclaim '(optimize (speed 0) (space 0) (safety 3) (debug 3)))~%")
    ; Use if happy...
    ;(format o "(proclaim '(optimize (speed 3) (space 3) (safety 0) (debug 0)))~%")
    (let c (compile-sections (list (. 'core nil))
                             :transpiler !)
      (adolist ((cl-packages))
        (late-print ! o))
      (late-print '(cl:in-package :tre-core) o)
      (adolist ((cl-wrappers))
        (princ ! o))
      (filter [late-print _ o] c)
      (late-print '(cl:in-package :tre) o)
      (late-print '(env-load "main.lisp") o))))
(quit)
