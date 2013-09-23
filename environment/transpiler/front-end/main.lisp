;;;; tré transpiler – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(env-load "transpiler/front-end/arith-wrappers.lisp" 'c)

(env-load "transpiler/front-end/cpr-count.lisp")
(env-load "transpiler/front-end/tag-convert.lisp")
(env-load "transpiler/front-end/expression-expand/argument-expand.lisp")
(env-load "transpiler/front-end/expression-expand/expression-expand.lisp")
(env-load "transpiler/front-end/expression-expand/funcalls.lisp")
(env-load "transpiler/front-end/expression-expand/set-global-variable-value.lisp")
(env-load "transpiler/front-end/lambda-expand.lisp")
(env-load "transpiler/front-end/rename-arguments.lisp")
(env-load "transpiler/front-end/expand-literal-characters.lisp")
(env-load "transpiler/front-end/define-compiled-literal.lisp")
(env-load "transpiler/front-end/backquote-expand.lisp")
(env-load "transpiler/front-end/compiler-macros.lisp")
(env-load "transpiler/front-end/expand.lisp")
(env-load "transpiler/front-end/toplevel.lisp")
