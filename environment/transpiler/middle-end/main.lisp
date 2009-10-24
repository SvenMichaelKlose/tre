;;;;; TRE transpiler/middle-end
;;;;; (c) 2005-2009 Sven Klose <pixel@copei.de>

(env-load "transpiler/middle-end/predicates.lisp")
(env-load "transpiler/middle-end/subatomic.lisp")
(env-load "transpiler/middle-end/verbose.lisp")
(env-load "transpiler/middle-end/compiled-list.lisp")
(env-load "transpiler/middle-end/with-lambda-call.lisp")

(env-load "transpiler/middle-end/funinfo/tree.lisp")
(env-load "transpiler/middle-end/funinfo/environment.lisp")
(env-load "transpiler/middle-end/funinfo/lexical.lisp")
(env-load "transpiler/middle-end/funinfo/lambda.lisp")
(env-load "transpiler/middle-end/funinfo/debug.lisp")
(env-load "transpiler/middle-end/rename-args.lisp")
(env-load "transpiler/middle-end/rename-tags.lisp")

(env-load "transpiler/middle-end/compiler-macros.lisp")
(env-load "transpiler/middle-end/quote-expand.lisp")
(env-load "transpiler/middle-end/place-expand.lisp")
(env-load "transpiler/middle-end/place-assign.lisp")
(env-load "transpiler/middle-end/lambda-expand.lisp")
(env-load "transpiler/middle-end/expression-expand.lisp")

(env-load "transpiler/middle-end/opt-peephole.lisp")
(env-load "transpiler/middle-end/opt-inline.lisp")
(env-load "transpiler/middle-end/opt-places.lisp")
