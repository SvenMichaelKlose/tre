;;;; TRE environment
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Boot up the environment

;; *UNIVERSE* contains the names of all top-level definitions that
;; shouldn't be removed by garbage collection.
(setq *universe*
	  (cons '%scope-toplevel-test
	  (cons '*environment-filenames*
	  (cons 'env-load
	  		*universe*)))) ; Interpreter already added elements.

;; Associative array of DEFVAR names and their initial forms.
(setq *variables*
	  (cons (cons '*environment-filenames* nil)
	  (cons (cons '*show-definitions* nil)
	  (cons (cons '*boot-image* nil)
	  (cons (cons '%launchfile nil)
	        nil)))))

(setq *environment-filenames* nil)

(setq %scope-toplevel-test 'some-test-value)

(%set-atom-fun env-load
  #'(lambda (path)
	  (setq *environment-filenames*
			(cons path *environment-filenames*))
      (load (string-concat *environment-path* "/environment/" path))))

(env-load "stage0/main.lisp")

(setq *show-definitions* t)
(if (eq *show-definitions* '*show-definitions*)
    (setq *show-definitions* nil))

(env-load "stage1/main.lisp")

(defun currently-defined-functions ()
  (copy-list *defined-functions*))

(defvar *functions-after-stage-1* (currently-defined-functions))

(defvar *assert* nil)
(env-load "stage2/main.lisp")

(defvar *functions-after-stage-2* (currently-defined-functions))

(env-load "stage3/main.lisp")
(defvar *functions-after-stage-3* (currently-defined-functions))

(env-load "stage4/main.lisp")
(defvar *functions-after-stage-4* (currently-defined-functions))

(env-load "lib/main.lisp")

(defvar *tre-has-math* t)
(defvar *tre-has-alien* t)
(defvar *tre-has-class* t)
(defvar *tre-has-editor* nil)
(defvar *tre-has-compiler* t)
(defvar *tre-has-transpiler* t)

(when *tre-has-math*
  (env-load "math/main.lisp"))
(defvar *universe-after-math* (copy-list *universe*))
(defvar *functions-after-math* (currently-defined-functions))

(when *tre-has-alien*
  (env-load "alien/main.lisp"))

(defvar *functions-after-alien* (currently-defined-functions))

(when *tre-has-transpiler*
  (env-load "oo/thisify.lisp"))

(when *tre-has-class*
  (unless *tre-has-transpiler*
    (env-load "oo/thisify.lisp"))
  (env-load "oo/class.lisp")
  (env-load "oo/ducktype.lisp")
  (env-load "oo/ducktype-test.lisp"))

(when *tre-has-editor*
  (env-load "editor/main.lisp"))

; Test lexical scoping.
(unless (eq %scope-toplevel-test 'some-test-value)
  (error "scope-toplevel test"))
(setq *UNIVERSE* (cdr *UNIVERSE*))

(when *tre-has-transpiler*
  (env-load "transpiler/main.lisp"))

; Keep tests for reuse in definition order.
(setq *tests* (reverse *tests*))

; Load file specified on command-line or loaded image.
(defun %load-launchfile ()
  (when %LAUNCHFILE
    (load %LAUNCHFILE)))

;; Dump fast-loadable image.
(defun dump-system ()
  (format t "; Dumping environment to image '~A': " *boot-image*)
  (force-output)
  (sys-image-create *boot-image* #'%load-launchfile)
  (format t " OK~%"))

(defvar *universe-functions* (currently-defined-functions))

(env-load "version.lisp")

(dump-system)
(%load-launchfile)
