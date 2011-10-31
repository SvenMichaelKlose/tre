;;;;; tré - Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	(with-temporary (transpiler-import-from-environment? tr) nil
	  (concat-stringtree
	      (mapcar (fn transpiler-backend tr _)
			      (mapcar (fn transpiler-middleend-2 tr _)
			  		      forms))))))

(defun transpiler-sighten (tr x)
  (mapcar (fn transpiler-frontend tr (list _)) x))

(defun transpiler-sighten-file (tr file)
  (format t "(LOAD \"~A\")~%" file)
  (transpiler-sighten tr (read-file-all file)))
