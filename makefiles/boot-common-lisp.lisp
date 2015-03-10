; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defun cl-packages ()
  `((defpackage "TRE-CORE"
      (:export       ,@(@ #'symbol-name
                          (+ +cl-direct-imports+
                             (carlist +cl-renamed-imports+)
                             *cl-builtins*
                             +core-variables+)))
      (:import-from  "COMMON-LISP" "NIL" "T"))
    (defpackage "TRE"
      (:use          "TRE-CORE")
      (:import-from  "COMMON-LISP" "NIL" "T")
      (:export       ,@(@ #'symbol-name +cl-special-forms+)))))

(defun cl-symbol (x)
  (make-symbol (symbol-name x) "COMMON-LISP"))

(defun cl-wrapper (x)
  (format nil "(cl:defun ~A (cl:&rest x) (cl:apply #'cl:~A x))~%" x. .x.))

(defun cl-wrappers ()
  (@ #'cl-wrapper
     (+ (@ [list _ _] +cl-direct-imports+)
        +cl-renamed-imports+)))

(alet (copy-transpiler *cl-transpiler*)
  (with-temporary *transpiler* !
    (add-defined-variable '*macros*))
;  (= (transpiler-dump-passes? !) t)
  (let c (compile-sections (list (. 'dummy nil)) :transpiler !)
    (with-output-file o "boot-common.lisp"
      (format o "(declaim #+sbcl(sb-ext:muffle-conditions compiler-note style-warning))~%")
      ; Use to debug...
      ;(format o "(proclaim '(optimize (speed 3) (space 0) (safety 3) (debug 2)))~%")
      ; Use if happy...
      ;(format o "(proclaim '(optimize (speed 3) (space 3) (safety 0) (debug 0)))~%")
      (adolist ((cl-packages))
        (late-print ! o))
      (late-print '(cl:in-package :tre-core) o)
      (adolist ((cl-wrappers))
        (princ ! o))
      (@ [late-print _ o] c)
      (princ "(cl:in-package :tre)" o)
      (princ "(cl:format t \"Loading environment...~%\")" o)
      (princ "(env-load \"main.lisp\")" o))))
(quit)
