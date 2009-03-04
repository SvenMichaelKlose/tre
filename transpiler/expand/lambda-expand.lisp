;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; LAMBDA EXPANSION

; XXX remove this
(defvar *is-imported-funinfo* nil)

(defun transpiler-lambda-expand-one (tr x)
  (with (forms (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x.))
         imported	(unless *is-imported-funinfo* ; XXX
					  (transpiler-current-funinfo tr))
         fi			(or imported
						(make-funinfo :env forms
							  		  :args forms)))
    (prog1
	  `#'(,(lambda-args x.)
             ,@(funcall (if imported
						    #'lambda-embed-or-export-transform
						    #'lambda-embed-or-export)
				   fi
                   (lambda-body x.)
                   (transpiler-lambda-export? tr)))
		  ; XXX not so good....
		  ; Avoid prepared FUNINFO from lambda-expansion.
          (when imported
			(setf *is-imported-funinfo* t))
          (dolist (e (funinfo-closures fi))
            (transpiler-add-exported-closure tr e. .e)
            (transpiler-add-wanted-function tr e.)))))

(defun transpiler-lambda-expand-0 (tr x)
  "Expand top-level LAMBDA expressions."
  (if (atom x)
	  x
	  (cons (if (lambda? x.)
				(transpiler-lambda-expand-one tr x)
				(transpiler-lambda-expand-0 tr x.))
		    (transpiler-lambda-expand-0 tr .x))))

(defun transpiler-lambda-expand (tr x)
  (setf *is-imported-funinfo* nil)
  (transpiler-lambda-expand-0 tr x))
