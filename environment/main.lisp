(env-load "stage0/main.lisp")
(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "version.lisp")
(env-load "stage4/main.lisp")
(env-load "stage5/main.lisp")

(& *tre-has-math*   (env-load "math/main.lisp"))
(& *tre-has-class*  (env-load "oo/class.lisp"))

(env-load "transpiler/main.lisp")

(env-load "read-eval-loop.lisp")

(env-load "print-html-script.lisp")
(env-load "lml-utils.lisp")
(env-load "lml2xml.lisp")

(= *tests* (reverse *tests*))

(env-load "reverse-tests.lisp")
(env-load "config-after-reload.lisp" :cl)
(env-load "write-image.lisp" :cl)
