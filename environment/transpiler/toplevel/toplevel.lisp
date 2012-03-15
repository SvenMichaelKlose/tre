;;;;; tré - Copyright (c) 2008-2010,2012 Sven Michael Klose <pixel@copei.de>

(defun transpiler-make-code (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	(with-temporary (transpiler-import-from-environment? tr) nil
	  (apply #'string-concat
	         (mapcar (fn transpiler-backend tr _)
			         (mapcar (fn transpiler-middleend-2 tr _)
			  		         forms))))))

(defun transpiler-sighten (tr x)
  (mapcar (fn transpiler-frontend tr (list _)) x))

(defun transpiler-sighten-file (tr file)
  (format t "(LOAD \"~A\")~%" file)
  (force-output)
  (transpiler-sighten tr (read-file-all file)))
