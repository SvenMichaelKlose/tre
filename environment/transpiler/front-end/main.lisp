; tré transpiler – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

(env-load "transpiler/front-end/arith-wrappers.lisp" :c)

(env-load "transpiler/front-end/cpr-count.lisp")
(env-load "transpiler/front-end/wrap-atoms.lisp")
(env-load "transpiler/front-end/gather-imports.lisp")
(env-load "transpiler/front-end/unassign-lambdas.lisp")
(env-load "transpiler/front-end/expression-expand.lisp")
(env-load "transpiler/front-end/lambda-expand.lisp")
(env-load "transpiler/front-end/thisify.lisp")
(env-load "transpiler/front-end/rename-arguments.lisp")
(env-load "transpiler/front-end/expand-literal-characters.lisp")
(env-load "transpiler/front-end/define-compiled-literal.lisp")
(env-load "transpiler/front-end/quote-expand.lisp")
(env-load "transpiler/front-end/compiler-macros.lisp")
(env-load "transpiler/front-end/macroexpand.lisp")
(env-load "transpiler/front-end/toplevel.lisp")
