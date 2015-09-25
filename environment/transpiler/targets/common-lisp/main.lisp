; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(env-load "transpiler/targets/common-lisp/imports.lisp" :cl)
(env-load "transpiler/targets/common-lisp/core.lisp" :cl)
(unless (symbol-function 'make-lambdas)
  (env-load "transpiler/targets/common-lisp/make-lambdas.lisp" :cl))
(env-load "transpiler/targets/common-lisp/toplevel.lisp" :cl)
(env-load "transpiler/targets/common-lisp/expand.lisp" :cl)
