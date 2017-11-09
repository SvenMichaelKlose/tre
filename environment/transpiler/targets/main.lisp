(defun has-target? (name)
  (member name *targets*))

(env-load "transpiler/targets/shared/main.lisp")

(? (has-target? :cl)
   (env-load "transpiler/targets/common-lisp/main.lisp"))
(? (has-target? :js)
   (env-load "transpiler/targets/javascript/main.lisp"))
(? (has-target? :php)
   (env-load "transpiler/targets/php/main.lisp"))

(env-load "transpiler/targets/shared/macroexpand/expand.lisp")
(env-load "transpiler/targets/shared/macroexpand/labels.lisp")
(env-load "transpiler/targets/shared/macroexpand/opt-filter.lisp")
(env-load "transpiler/targets/shared/macroexpand/=-slot-value.lisp")
