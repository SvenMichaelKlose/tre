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

(setq *show-definitions* t)
(if (eq *show-definitions* '*show-definitions*)
    (setq *show-definitions* nil))

(env-load "stage1/main.lisp")

(defvar *universe-after-stage-1* (copy-list *universe*))
(defvar *functions-after-stage-1*
		(%simple-mapcar (fn (when (and (symbolp _)
                                       (not (builtinp _))
                                       (symbol-function _))
                              `(function ,_)))
                		*universe*))

(defvar *assert* nil)
(env-load "stage2/main.lisp")

(defvar *universe-after-stage-2* (copy-list *universe*))
(defvar *functions-after-stage-2*
		(%simple-mapcar (fn (when (and (symbolp _)
                                       (not (builtinp _))
                                       (symbol-function _))
                              `(function ,_)))
                		*universe*))

(env-load "stage3/main.lisp")
(defvar *universe-after-stage-3* (copy-list *universe*))
(defvar *functions-after-stage-3*
		(%simple-mapcar (fn (when (and (symbolp _)
                                       (not (builtinp _))
                                       (symbol-function _))
                      		  `(function ,_)))
                		*universe*))

(setf *functions-after-stage-1* (reverse *functions-after-stage-1* ))
(setf *functions-after-stage-2* (reverse *functions-after-stage-2* ))
(setf *functions-after-stage-3* (reverse *functions-after-stage-3* ))

(env-load "stage4/main.lisp")

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
(defvar *functions-after-math*
		(%simple-mapcar (fn (when (and (symbolp _)
                                       (not (builtinp _))
                                       (symbol-function _))
                      		  `(function ,_)))
                		*universe*))

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
  (env-load "compiler/main.lisp"))

(when *tre-has-transpiler*
  (env-load "transpiler/main.lisp"))

; Keep tests for reuse in definition order.
(setq *tests* (reverse *tests*))

(defvar *universe-functions*
		(%simple-mapcar (fn (when (and (symbolp _)
                                       (not (builtinp _))
                                       (symbol-function _))
                              `(function ,_)))
                		(reverse *universe*)))

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
