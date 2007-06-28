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

(when %launchfile
  (load %launchfile))

(setq *tests* (reverse *tests*))
