;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defvar *exported-lambdas* nil)

;;; PUBLIC

(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	; Switch off checks for things to import.
	(with-temporary (transpiler-import-from-environment? tr) nil
	  (mapcar (fn transpiler-backend tr _)
			  (mapcar (fn transpiler-middleend-2 tr _)
			  		  forms)))))

(defun transpiler-sighten (tr x)
  (when (transpiler-lambda-export? tr)
	(setf *exported-lambdas* t))
  (mapcar (fn transpiler-middleend-1 tr (transpiler-front-end tr (list _)))
		  x))

(defun transpiler-sighten-files (tr files)
  (mapcan (fn (format t "(LOAD \"~A\")~%" _)
        	  (transpiler-sighten tr (read-file-all _)))
		  files))
