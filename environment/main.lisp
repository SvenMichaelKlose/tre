(env-load "stage0/main.lisp")
(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "version.lisp")
(env-load "stage4/main.lisp")
(env-load "stage5/main.lisp")

(& *tre-has-math*       (env-load "math/main.lisp"))
(when *tre-has-class*   (env-load "oo/class.lisp"))

(env-load "transpiler/main.lisp")

(env-load "read-eval-loop.lisp")

(env-load "platforms/shared/html/doctypes.lisp")    ; TODO: Remove these. Think up some tpm or something...
(env-load "platforms/shared/html/script.lisp")
(env-load "platforms/shared/lml.lisp")
(env-load "platforms/shared/lml2xml.lisp")

(env-load "reverse-tests.lisp")
(env-load "config-after-reload.lisp" :cl)
(env-load "write-image.lisp" :cl)
