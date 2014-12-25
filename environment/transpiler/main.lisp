; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@hugbox.org>

;,(awhen (& (function? #'%%=-transpiler-save-argument-defs-only?)
;           *transpiler*)
;   (%%usetf-transpiler-save-argument-defs-only? t !))

(env-load "transpiler/lib/main.lisp")
(env-load "transpiler/back-end/main.lisp")
(env-load "transpiler/middle-end/main.lisp")
(env-load "transpiler/front-end/main.lisp")
(env-load "transpiler/warn-unused-functions.lisp")
(env-load "transpiler/tests.lisp")
(env-load "transpiler/import.lisp")
(env-load "transpiler/generic-compile.lisp")
(env-load "transpiler/targets/main.lisp")
(env-load "transpiler/compile.lisp")
(env-load "transpiler/compile-environment.lisp" :c)
(env-load "transpiler/eval.lisp" :c)
(env-load "transpiler/make-project.lisp" :c)
