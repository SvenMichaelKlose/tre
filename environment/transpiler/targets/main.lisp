(env-load "transpiler/targets/shared/main.lisp")

(fn has-target? (name)
  (member name *targets*))

(? (has-target? :cl)
   (env-load "transpiler/targets/common-lisp/main.lisp"))
(? (has-target? :js)
   (env-load "transpiler/targets/javascript/main.lisp"))
(? (has-target? :php)
   (env-load "transpiler/targets/php/main.lisp"))

(env-load "transpiler/targets/shared/transpiler-macros/defun.lisp")
(env-load "transpiler/targets/shared/transpiler-macros/def-shared-transpiler-macro.lisp")
(env-load "transpiler/targets/shared/transpiler-macros/labels.lisp")
(env-load "transpiler/targets/shared/transpiler-macros/slot-value.lisp")
(env-load "transpiler/targets/shared/class.lisp")
