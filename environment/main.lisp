(env-load "stage0/main.lisp")
(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "stage4/main.lisp")
(env-load "stage5/main.lisp")
(& *tre-has-math*   (env-load "math/main.lisp"))
(& *tre-has-class*  (env-load "oo/class.lisp"))
(env-load "utils/version.lisp")
(env-load "transpiler/main.lisp")
(env-load "read-eval-loop.lisp")

(env-load "utils/lml-utils.lisp")
(env-load "utils/lml2xml.lisp")
(env-load "utils/print-html-script.lisp")

(env-load "todo.lisp")

(env-load "tests/main.lisp")

(env-load "config-after-reload.lisp" :cl)

(env-load "make-vim-syntax.lisp" :cl)
(env-load "utils/write-image.lisp" :cl)
