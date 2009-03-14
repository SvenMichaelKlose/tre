;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand-one (tr x)
  (with (forms (argument-expand-names
			       'transpiler-lambda-expand
			       (lambda-args x.))
         imported	(get-lambda-funinfo x.)
         fi			(or imported
						(make-funinfo :env forms
							  		  :args forms)))
    (prog1
	  `#'(,@(make-lambda-funinfo fi)
		  ,(lambda-args x.)
             ,@(funcall (if imported
						    #'lambda-embed-or-export-transform
						    #'lambda-embed-or-export)
				   fi
                   (lambda-body x.)
                   (transpiler-lambda-export? tr)))
	  (dolist (i (funinfo-closures fi))
		(transpiler-add-exported-closure tr i)))))

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
