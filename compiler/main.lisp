;;;;; nix operating system project
;;;;; lisp compiler
;;;;; (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Compiler toplevel.

;;;; Miscellaneous.
(env-load "../lib/tree-walk.lisp")
(env-load "../compiler/verbose.lisp")
(env-load "../compiler/utils.lisp")
(env-load "../compiler/lambda.lisp")
(env-load "../compiler/predicates.lisp")
(env-load "../compiler/funinfo.lisp")

;;;; Expansion.
;;;;
;;;; Transforms toplevel expressions into virtual code.
(env-load "../compiler/quote-expand.lisp")
(env-load "../compiler/compiler-macros.lisp")
(env-load "../compiler/stack-arguments.lisp")
(env-load "../compiler/lambda-expand.lisp")
(env-load "../compiler/expression-expand.lisp")
(env-load "../compiler/tree-expand.lisp")

;;;; Optimisation.
;(env-load "../compiler/opt-constfold.lisp")
;(env-load "../compiler/opt-double.lisp")
;(env-load "../compiler/opt-unused.lisp")
;(env-load "../compiler/optimise.lisp")

;;;; Code generation.
;(env-load "../compiler/cpu.lisp")
;(env-load "../compiler/gencode.lisp")

;;;; Machine definitions.
;(env-load "../compiler/cpu-x86.lisp")

;;;; Toplevel.
(env-load "../compiler/compile.lisp")

;; Set this if EVAL should COMPILE.
;(defvar *compiler-hook* t)
;(compile-everything)
