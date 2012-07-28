;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

,(awhen (& (function? #'%%usetf-transpiler-save-argument-defs-only?)
           *current-transpiler*)
   (%%usetf-transpiler-save-argument-defs-only? t !))

(env-load "transpiler/lib/main.lisp")
(env-load "transpiler/back-end/main.lisp")
(env-load "transpiler/middle-end/main.lisp")
(env-load "transpiler/front-end/main.lisp")
(env-load "transpiler/toplevel/main.lisp")

(env-load "transpiler/targets/shared/main.lisp")
(env-load "transpiler/targets/c/main.lisp")
(env-load "transpiler/targets/bytecode/main.lisp")
(env-load "transpiler/targets/javascript/main.lisp")
(env-load "transpiler/targets/php/main.lisp")
(env-load "transpiler/targets/precompile-environments.lisp")

(env-load "transpiler/compile.lisp")
