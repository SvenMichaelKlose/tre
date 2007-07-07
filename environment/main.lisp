;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Environment toplevel

(setq *universe* (cons 'env-load *universe*))

(%set-atom-fun env-load
  #'(lambda (path)
      (load (string-concat *environment-path* "/environment/" path))))

(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "../compiler/main.lisp")

; Keep tests for reuse in definition order.
(setq *tests* (reverse *tests*))

(defun %load-launchfile ()
  (do-tests *tests*)
  (when %launchfile
    (load %launchfile)))

(format t "Dump to image '~A': " *boot-image*)(force-output)
(sys-image-create *boot-image* #'%load-launchfile)
(format t "OK~%")
(%load-launchfile)
