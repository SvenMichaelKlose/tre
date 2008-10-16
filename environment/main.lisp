;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Environment toplevel

(setq *UNIVERSE* (cons '%scope-toplevel-test (cons 'env-load *UNIVERSE*))
	  %scope-toplevel-test 'some-test-value)

(%SET-ATOM-FUN env-load
  #'(lambda (path)
      (load (string-concat *ENVIRONMENT-PATH* "/environment/" path))))

(env-load "stage0/main.lisp")
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
(env-load "../transpiler/utils.lisp")
(env-load "../transpiler/config.lisp")
(env-load "../transpiler/thisify.lisp")
(env-load "../transpiler/expand.lisp")
(env-load "../transpiler/identifier.lisp")
(env-load "../transpiler/codegen.lisp")
(env-load "../transpiler/obfuscate.lisp")
(env-load "../transpiler/toplevel.lisp")
(env-load "../transpiler/javascript/config.lisp")
(env-load "../transpiler/javascript/expand.lisp")
(env-load "../transpiler/javascript/codegen.lisp")
(env-load "../transpiler/javascript/core.lisp")
(env-load "../transpiler/javascript/toplevel.lisp")
(env-load "../transpiler/c/config.lisp")
(env-load "../transpiler/c/expand.lisp")
(env-load "../transpiler/c/codegen.lisp")
(env-load "../transpiler/c/core.lisp")
(env-load "../transpiler/c/toplevel.lisp")

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
