;;;;; TRE compiler
;;;;; (c) 2005-2011 Sven Klose <pixel@copei.de>

(env-load "transpiler/lib/c-newlines.lisp")
(env-load "transpiler/lib/c-literal-string.lisp")
(env-load "transpiler/lib/predicates.lisp")
(env-load "transpiler/lib/subatomic.lisp")
(env-load "transpiler/lib/tag.lisp")
(env-load "transpiler/lib/verbose.lisp")
(env-load "transpiler/lib/compiled-list.lisp")
(env-load "transpiler/lib/with-lambda-call.lisp")
(env-load "transpiler/lib/with-lambda-content.lisp")
(env-load "transpiler/lib/function-arguments.lisp")
(env-load "transpiler/lib/simple-argument-list-p.lisp")
(env-load "transpiler/lib/pass.lisp")

(env-load "transpiler/lib/transpiler/transpiler.lisp")
(env-load "transpiler/lib/transpiler/import.lisp")

(env-load "transpiler/lib/funinfo/funinfo.lisp")
(env-load "transpiler/lib/funinfo/environment.lisp")
(env-load "transpiler/lib/funinfo/lexical.lisp")
(env-load "transpiler/lib/funinfo/lambda.lisp")
(env-load "transpiler/lib/funinfo/debug.lisp")
(env-load "transpiler/lib/funinfo/global.lisp")

(env-load "transpiler/lib/copy-lambda.lisp")
(env-load "transpiler/lib/meta-code.lisp")
(env-load "transpiler/lib/metacode-walker.lisp")
(env-load "transpiler/lib/meta-code-test.lisp")
(env-load "transpiler/lib/compile-argument-expansion.lisp")
