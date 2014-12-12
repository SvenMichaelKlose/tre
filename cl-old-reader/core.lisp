;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)


;;; Wrapped functions.

(defmacro define-wrappers ()
  `(progn
     ,@(mapcar #'(lambda (x)
                   `(defun ,(values (intern (symbol-name (car x)) "TRE-CORE")) (&rest x)
                      (apply (function ,(cadr x)) x)))
               +renamed-imports+)))

(define-wrappers)


;;; Global variables.

(defvar *universe* nil)
(defvar *launchfile* nil)
(defvar *pointer-size* 4)
(defvar *assert* '*assert*)
(defvar *targets* '*targets*)
(defvar *endianess* nil)
(defvar *cpu-type* nil)
(defvar *libc-path* nil)
(defvar *rand-max* nil)
(defvar *default-listprop* nil)


;;; Implementations.

(defun print-definition (x) (print x))

(load "cl-old-reader/utils.lisp")
(load "cl-old-reader/stream-wrapper.lisp")
(load "cl-old-reader/function-source.lisp")
(load "environment/stage2/while.lisp")
(load "cl-old-reader/argument-expand.lisp")

(load "cl-old-reader/array.lisp")
(load "cl-old-reader/file.lisp")
(load "cl-old-reader/hash-table.lisp")
(load "cl-old-reader/image.lisp")
(load "cl-old-reader/list.lisp")
(load "cl-old-reader/number.lisp")
(load "cl-old-reader/object.lisp")
(load "cl-old-reader/string.lisp")
(load "cl-old-reader/symbol.lisp")
(load "cl-old-reader/variable.lisp")

(load "cl-old-reader/backquote-expand.lisp")
(load "cl-old-reader/macroexpand.lisp")
(load "cl-old-reader/macro.lisp")
(load "cl-old-reader/function.lisp")
(load "cl-old-reader/eval.lisp")
(load "cl-old-reader/read.lisp")
(load "cl-old-reader/load.lisp")

(load "cl-old-reader/not-implemented.lisp")
(load "cl-old-reader/builtins.lisp")

(defun %start-core ()
  (setf *launchfile* (cadr (or
                             #+SBCL sb-ext:*posix-argv*
                             #+LISPWORKS system:*line-arguments-list*
                             #+CMU extensions:*command-line-words*
                             nil))))

(defun quit (&optional exit-code) (sb-ext:quit :unix-status exit-code))
