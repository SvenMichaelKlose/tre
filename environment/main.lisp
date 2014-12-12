;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "stage4/main.lisp")
(env-load "stage5/main.lisp")
(env-load "lib/main.lisp")
;(& *tre-has-math*       (env-load "math/main.lisp"))
;(& *tre-has-alien*      (env-load "alien/main.lisp" 'c))
(when *tre-has-class*   (env-load "oo/class.lisp"))
;                        (env-load "oo/ducktype.lisp")
;                        (env-load "oo/ducktype-test.lisp")
(env-load "transpiler/main.lisp")

(env-load "read-eval-loop.lisp")

(env-load "platforms/shared/html/doctypes.lisp")
(env-load "platforms/shared/html/script.lisp")
(env-load "platforms/shared/lml.lisp")
(env-load "platforms/shared/lml2xml.lisp")

(setq *tests* (reverse *tests*))

(defun %load-launchfile ()
  (%start-core)
  (awhen *launchfile*
    (load !))
  (read-eval-loop))

(defun dump-system (path)
  (format t "; Dumping environment to image '~A': ~F" path)
  (sys-image-create path #'%load-launchfile)
  (format t " OK~%"))

(env-load "version.lisp")
(env-load "config-after-reload.lisp")

;(= (transpiler-dump-passes? *c-transpiler*) t)

(defun expr2cl (x)                 (make-lambdas (macroexpand x)))
(defun file2cl (pathname)          (expr2cl (read-file pathname)))
(defun files2cl (&rest pathnames)  (. 'progn (mapcan #'file2cl pathnames)))

(with-output-file o "cl/read.lisp"
  (adolist (`((in-package :tre-parallel)
              ,@(expr2cl (cdr (read-file "cl/user.lisp")))
              ,@(files2cl "environment/stage0/config-defaults.lisp"
                          "environment/stage0/functional.lisp"
                          "environment/stage0/print-definition.lisp"
                          "environment/stage1/funcall.lisp"
                          "environment/stage1/comparison-c.lisp"
                          "environment/stage2/values.lisp"
                          "environment/stage2/range.lisp"
                          "environment/stage2/char.lisp"
                          "environment/stage2/char-predicates.lisp"
                          "environment/stage2/search-sequence.lisp"
                          "environment/stage3/terpri.lisp"
                          "environment/stage3/line.lisp"
                          "environment/stage4/split.lisp"
                          "cl/stream-wrapper.lisp"
                          "environment/stage3/read.lisp")))
    (unless (eq 'progn !)
    (print (late-print ! o)))))

(dump-system "image")
