;;;;; tré - Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>

;; *UNIVERSE* contains the names of all top-level definitions that
;; shouldn't be removed by the garbage collector.
(setq *universe*
	  (cons '%scope-toplevel-test
	  (cons '*environment-filenames*
	  (cons 'env-load
	  		*universe*)))) ; The interpreter already added elements.

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
  #'((path &optional (back-end nil))
	  (setq *environment-filenames* (cons (cons path back-end) *environment-filenames*))
      (load (string-concat *environment-path* "/environment/" path))))

(env-load "stage0/config-early.lisp" 'c)
(env-load "stage0/main.lisp" 'c)
(env-load "stage0/config.lisp" 'c)

(env-load "stage1/main.lisp")

(defun currently-defined-functions ()
  (copy-list *defined-functions*))

(defvar *functions-after-stage-1* (currently-defined-functions))

(env-load "stage2/main.lisp")

(defvar *functions-after-stage-2* (currently-defined-functions))

(env-load "stage3/main.lisp")
(defvar *functions-after-stage-3* (currently-defined-functions))

(env-load "stage4/main.lisp")
(defvar *functions-after-stage-4* (currently-defined-functions))

(env-load "stage5/main.lisp")
(defvar *functions-after-stage-5* (currently-defined-functions))

(env-load "lib/main.lisp")

(when *tre-has-math*
  (env-load "math/main.lisp"))
(defvar *universe-after-math* (copy-list *universe*))
(defvar *functions-after-math* (currently-defined-functions))

(when *tre-has-alien*
  (env-load "alien/main.lisp" 'c))

(defvar *functions-after-alien* (currently-defined-functions))

(when *tre-has-transpiler*
  (env-load "oo/thisify.lisp"))

(when *tre-has-class*
  (unless *tre-has-transpiler*
    (env-load "oo/thisify.lisp"))
  (env-load "oo/class.lisp")
;  (env-load "oo/ducktype.lisp")
;  (env-load "oo/ducktype-test.lisp")
  (env-load "oo/transpiler.lisp"))

(when *tre-has-editor*
  (env-load "editor/main.lisp"))

; Test lexical scoping.
(unless (eq %scope-toplevel-test 'some-test-value)
  (error "scope toplevel test"))
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
(format t "; Revision ~A.~%" *tre-revision*)

(dump-system)
(%load-launchfile)
