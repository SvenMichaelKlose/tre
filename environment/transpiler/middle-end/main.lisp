;;;;; TRE compiler
;;;;; (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Compiler toplevel.

(env-load "compiler/predicates.lisp")
(env-load "compiler/subatomic.lisp")
(env-load "compiler/verbose.lisp")
(env-load "compiler/compiled-list.lisp")
(env-load "compiler/with-lambda-call.lisp")

(env-load "compiler/funinfo/tree.lisp")
(env-load "compiler/funinfo/environment.lisp")
(env-load "compiler/funinfo/lexical.lisp")
(env-load "compiler/funinfo/lambda.lisp")
(env-load "compiler/funinfo/debug.lisp")
(env-load "compiler/rename-args.lisp")
(env-load "compiler/rename-tags.lisp")

(env-load "compiler/compiler-macros.lisp")
(env-load "compiler/quote-expand.lisp")
(env-load "compiler/place-expand.lisp")
(env-load "compiler/place-assign.lisp")
(env-load "compiler/lambda-expand.lisp")
(env-load "compiler/expression-expand.lisp")

(env-load "compiler/opt-peephole.lisp")
(env-load "compiler/opt-inline.lisp")
(env-load "compiler/opt-places.lisp")
