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

(load "cl/utils.lisp")
(load "environment/stage2/while.lisp")
(load "cl/backquote-expand.lisp")
(load "cl/read.lisp")
(load "cl/argument-expand.lisp")

(load "cl/array.lisp")
(load "cl/file.lisp")
(load "cl/hash-table.lisp")
(load "cl/image.lisp")
(load "cl/list.lisp")
(load "cl/number.lisp")
(load "cl/object.lisp")
(load "cl/string.lisp")
(load "cl/symbol.lisp")
(load "cl/variable.lisp")

(load "cl/macroexpand.lisp")
(load "cl/macro.lisp")
(load "cl/function.lisp")
(load "cl/eval.lisp")
(load "cl/load.lisp")

(load "cl/not-implemented.lisp")
(load "cl/builtins.lisp")

(defun %start-core ()
  (setf *launchfile* (cadr (or
                             #+SBCL sb-ext:*posix-argv*
                             #+LISPWORKS system:*line-arguments-list*
                             #+CMU extensions:*command-line-words*
                             nil))))

(defun quit (&optional exit-code) (sb-ext:quit :unix-status exit-code))
