;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; First, minimal environment

(env-load "stage1/backquote.lisp")
(env-load "stage1/macroexpand.lisp")
(env-load "stage1/simple-defines.lisp")
(env-load "stage1/basic-list.lisp")
(env-load "stage1/cons.lisp")
(env-load "stage1/gensym.lisp")
(env-load "stage1/defmacro.lisp")
(env-load "stage1/define-test.lisp")
(env-load "stage1/tests-builtins.lisp")

(env-load "stage1/listp.lisp")
(env-load "stage1/simple-mapcar.lisp")
(env-load "stage1/let.lisp")
(env-load "stage1/math.lisp")
(env-load "stage1/basic-conditional.lisp")

(env-load "stage1/defun.lisp")
(env-load "stage1/predicates.lisp")
(env-load "stage1/anaphoric.lisp")
(env-load "stage1/comparison.lisp")
(env-load "stage1/member.lisp")
(env-load "stage1/set.lisp")
(env-load "stage1/setf-builtin.lisp")
(env-load "stage1/incdec.lisp")
(env-load "stage1/eval.lisp")
(env-load "stage1/queue.lisp")
(env-load "stage1/conditional.lisp")
(env-load "stage1/stack.lisp")
(env-load "stage1/list-traversal.lisp")
(env-load "stage1/list-synonyms.lisp")
(env-load "stage1/lambda.lisp")
(env-load "stage1/loops.lisp")
(env-load "stage1/labels.lisp")
(env-load "stage1/test-lexical-scope.lisp")
