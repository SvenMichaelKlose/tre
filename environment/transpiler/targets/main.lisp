; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@copei.de>

(defun has-target? (name)
  (member name *targets*))

(env-load "transpiler/targets/shared/main.lisp")

(? (has-target? :bc)
   (env-load "transpiler/targets/bytecode/main.lisp"))
(? (has-target? :c)
   (env-load "transpiler/targets/c/main.lisp"))
(? (has-target? :cl)
   (env-load "transpiler/targets/common-lisp/main.lisp"))
(? (has-target? :js)
   (env-load "transpiler/targets/javascript/main.lisp"))
(? (has-target? :php)
   (env-load "transpiler/targets/php/main.lisp"))

(env-load "transpiler/targets/shared/expand/expand.lisp")
(env-load "transpiler/targets/shared/expand/labels.lisp")
(env-load "transpiler/targets/shared/expand/opt-filter.lisp")
