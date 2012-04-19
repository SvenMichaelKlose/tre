;;;;; tré - Copyright (c) 2005-2012 Sven Michael Klose <pixel@copei.de>

;,(awhen *current-transpiler*
;   (setf (transpiler-save-argument-defs-only? *current-transpiler*) t))

(env-load "transpiler/lib/main.lisp")
(env-load "transpiler/back-end/main.lisp")
(env-load "transpiler/middle-end/main.lisp")
(env-load "transpiler/front-end/main.lisp")
(env-load "transpiler/toplevel/main.lisp")

(env-load "transpiler/targets/shared/main.lisp")
(env-load "transpiler/targets/c/main.lisp")
(env-load "transpiler/targets/javascript/main.lisp")
(env-load "transpiler/targets/php/main.lisp")

(env-load "transpiler/compile.lisp")
