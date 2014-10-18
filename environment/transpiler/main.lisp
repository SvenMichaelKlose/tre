;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

,(awhen (& (function? #'%%=-transpiler-save-argument-defs-only?)
           *transpiler*)
   (%%usetf-transpiler-save-argument-defs-only? t !))

(env-load "transpiler/lib/main.lisp")
(env-load "transpiler/back-end/main.lisp")
(env-load "transpiler/middle-end/main.lisp")
(env-load "transpiler/front-end/main.lisp")

(env-load "transpiler/warn-unused-functions.lisp")
(env-load "transpiler/init.lisp")
(env-load "transpiler/tests.lisp")
(env-load "transpiler/import.lisp")
(env-load "transpiler/generic-compile.lisp")

(defun has-target? (name)
  (member name *targets*))

(env-load "transpiler/targets/shared/main.lisp")
(? (has-target? 'c)
   (env-load "transpiler/targets/c/main.lisp"))
(? (has-target? 'bc)
   (env-load "transpiler/targets/bytecode/main.lisp"))
(? (has-target? 'js)
   (env-load "transpiler/targets/javascript/main.lisp"))
(? (has-target? 'php)
   (env-load "transpiler/targets/php/main.lisp"))
(env-load "transpiler/targets/shared/expand/expand.lisp")
(env-load "transpiler/targets/shared/expand/opt-filter.lisp")
(env-load "transpiler/targets/precompile-environments.lisp")

(env-load "transpiler/compile.lisp")
(env-load "transpiler/compile-environment.lisp" 'c)

(env-load "transpiler/eval.lisp" 'c)

(env-load "transpiler/make-project.lisp" 'c)
