;;;; TRE environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Boot up the environment

(setq *UNIVERSE* (cons '%scope-toplevel-test (cons 'env-load *UNIVERSE*))
	  %scope-toplevel-test 'some-test-value)

(%set-atom-fun env-load
  #'(lambda (path)
      (load (string-concat *ENVIRONMENT-PATH* "/environment/" path))))

(env-load "stage0/main.lisp")
(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "stage4/main.lisp")

(env-load "../lib/main.lisp")

(defvar *tre-has-math* t)
(defvar *tre-has-alien* t)
(defvar *tre-has-class* t)
(defvar *tre-has-editor* nil)
(defvar *tre-has-compiler* t)
(defvar *tre-has-transpiler* t)

(when *tre-has-math*
  (env-load "math/main.lisp"))

(when *tre-has-alien*
  (env-load "alien/main.lisp"))

(when (or *tre-has-class*
		  *tre-has-transpiler*)
  (env-load "oo/thisify.lisp"))
(when *tre-has-class*
  (env-load "oo/class.lisp")
  (env-load "oo/ducktype.lisp")
  (env-load "oo/ducktype-test.lisp"))

(when *tre-has-editor*
  (env-load "editor/main.lisp"))

; Test lexical scoping.
(unless (eq %scope-toplevel-test 'some-test-value)
  (error "scope-toplevel test"))
(setq *UNIVERSE* (cdr *UNIVERSE*))

(when *tre-has-compiler*
  (env-load "../compiler/main.lisp"))

(when *tre-has-transpiler*
  (env-load "../transpiler/main.lisp"))

; Keep tests for reuse in definition order.
(setq *tests* (reverse *tests*))

; Load file specified on command-line or loaded image.
(defun %load-launchfile ()
  (when %LAUNCHFILE
    (load %LAUNCHFILE)))

; Dump fast-loadable image.
(format t "; Dump to image '~A': " *BOOT-IMAGE*)
(force-output)
(sys-image-create *BOOT-IMAGE* #'%load-launchfile)
(format t " OK~%")

(%load-launchfile)
