;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(setq *milestone* nil)

;; The garbage collector keeps everything that's connected to *UNIVERSE*.
(setq *universe*
	  (cons '*environment-filenames*
	  (cons 'env-load
	  		*universe*)))

(setq *variables*
	  (cons (cons '*environment-filenames* nil)
	  (cons (cons '*show-definitions?* nil)
	  (cons (cons '*boot-image* nil)
	  (cons (cons '%launchfile nil)
	        nil)))))

(setq *environment-filenames* nil)

(%set-atom-fun env-load
  #'((path &optional (back-end nil))
	  (setq *environment-filenames* (cons (cons path back-end) *environment-filenames*))
      (load (string-concat *environment-path* "/environment/" path))))

(env-load "stage0/main.lisp" 'c)
(env-load "stage1/main.lisp")
(env-load "stage2/main.lisp")
(env-load "stage3/main.lisp")
(env-load "stage4/main.lisp")
(env-load "stage5/main.lisp")
(env-load "lib/main.lisp")
(& *tre-has-math*       (env-load "math/main.lisp"))
(& *tre-has-alien*      (env-load "alien/main.lisp" 'c))
(when *tre-has-class*   (env-load "oo/class.lisp"))
;                        (env-load "oo/ducktype.lisp")
;                        (env-load "oo/ducktype-test.lisp")
(& *tre-has-editor*     (env-load "editor/main.lisp"))
(env-load "transpiler/main.lisp")

(env-load "read-eval-loop.lisp")

(env-load "platforms/shared/html/doctypes.lisp")
(env-load "platforms/shared/html/script.lisp")
(env-load "platforms/shared/lml.lisp")
(env-load "platforms/shared/lml2xml.lisp")

(setq *tests* (reverse *tests*))

(defun dump-system (path)
  (format t "; Dumping environment to image '~A': ~F" path)
  (sys-image-create path #'%load-launchfile)
  (format t " OK~%"))

(defun %load-launchfile ()
  (awhen %LAUNCHFILE
    (load !)))

(defvar *universe-functions* (copy-list *defined-functions*))

(env-load "version.lisp")
(env-load "config-after-reload.lisp")

(dump-system "image")
(%load-launchfile)
