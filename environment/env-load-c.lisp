;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

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
  #'((path &optional (target nil))
	  (setq *environment-filenames* (cons (cons path target) *environment-filenames*))
      (load (string-concat *environment-path* "/environment/" path))))

(env-load "stage0/main.lisp")
(env-load "main.lisp")
