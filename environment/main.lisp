;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Environment toplevel

(setq *UNIVERSE* (cons '%scope-toplevel-test (cons 'env-load *UNIVERSE*))
	  %scope-toplevel-test 'some-test-value)

(%SET-ATOM-FUN env-load
  #'(lambda (path)
      (load (string-concat *ENVIRONMENT-PATH* "/environment/" path))))

(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "alien/main.lisp")
(env-load "editor/main.lisp")

; Test lexical scoping.
(unless (eq %scope-toplevel-test 'some-test-value)
  (error "scope-toplevel test"))
(setq *UNIVERSE* (cdr *UNIVERSE*))

(env-load "../compiler/main.lisp")

; Keep tests for reuse in definition order.
(setq *tests* (reverse *tests*))

(defun %load-launchfile ()
  (when %LAUNCHFILE
    (load %LAUNCHFILE)))

(gc)
(format t "Dump to image '~A': " *BOOT-IMAGE*)(force-output)
(sys-image-create *BOOT-IMAGE* #'%load-launchfile)
(format t "OK~%")
(%load-launchfile)
