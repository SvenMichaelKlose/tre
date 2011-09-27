;;;; tré transpiler - Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

(env-load "transpiler/front-end/arith-wrappers.lisp")

(env-load "transpiler/front-end/expression-expand/expression-expand.lisp")
(env-load "transpiler/front-end/expression-expand/guest-utils.lisp")
(env-load "transpiler/front-end/expression-expand/funcalls.lisp")
(env-load "transpiler/front-end/expression-expand/funinfo.lisp")
(env-load "transpiler/front-end/expression-expand/global-variables.lisp")
(env-load "transpiler/front-end/lambda-expand.lisp")
(env-load "transpiler/front-end/rename-args.lisp")
(env-load "transpiler/front-end/rename-tags.lisp")
(env-load "transpiler/front-end/opt-inline.lisp")
(env-load "transpiler/front-end/literals.lisp")
(env-load "transpiler/front-end/backquote-expand.lisp")
(env-load "transpiler/front-end/package.lisp")
(env-load "transpiler/front-end/compiler-macros.lisp")
(env-load "transpiler/front-end/expand.lisp")
(env-load "transpiler/front-end/toplevel.lisp")
