;;;; TRE transpiler
;;;; Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>

(env-load "transpiler/lib/main.lisp")
(env-load "transpiler/back-end/main.lisp")
(env-load "transpiler/middle-end/main.lisp")
(env-load "transpiler/front-end/main.lisp")
(env-load "transpiler/toplevel/main.lisp")

(env-load "transpiler/targets/shared/main.lisp")
(env-load "transpiler/targets/c/main.lisp")
(env-load "transpiler/targets/javascript/main.lisp")
;(env-load "transpiler/targets/php/main.lisp")
