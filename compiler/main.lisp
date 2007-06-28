;;;;; nix operating system project
;;;;; lisp compiler
;;;;; (c) 2005 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LISP compiler toplevel

;;;; Miscellaneous

(env-load "../lib/tree-walk.lisp")
(env-load "../compiler/verbose.lisp")
(env-load "../compiler/utils.lisp")
(env-load "../compiler/lambda.lisp")
(env-load "../compiler/predicates.lisp")
(env-load "../compiler/funinfo.lisp")

;;;; Expansion

(env-load "../compiler/compiler-macros.lisp")
(env-load "../compiler/stack-arguments.lisp")
(env-load "../compiler/lambda-expand.lisp")
(env-load "../compiler/expression-expand.lisp")
(env-load "../compiler/tree-expand.lisp")

;;;; Toplevel

(env-load "../compiler/compile.lisp")

;(defvar *compiler-hook* t)
;(compile-everything)
