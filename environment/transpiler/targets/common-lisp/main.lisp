; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(env-load "transpiler/targets/common-lisp/imports.lisp")
(env-load "transpiler/targets/common-lisp/core.lisp")
(unless (symbol-function 'make-lambdas)
  (env-load "transpiler/targets/common-lisp/make-lambdas.lisp"))
(env-load "transpiler/targets/common-lisp/toplevel.lisp")
(env-load "transpiler/targets/common-lisp/expand.lisp")
