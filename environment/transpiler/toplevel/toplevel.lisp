;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Toplevel

(defun transpiler-expand-and-generate-code (tr forms)
  (transpiler-generate-code tr
	(transpiler-expand tr forms)))

(defvar *exported-lambdas* nil)

;;; PUBLIC

;; User code must have been sightened by TRANSPILER-SIGHT.
(defun transpiler-transpile (tr forms)
  (unless (eq t (transpiler-unwanted-functions tr))
	; Switch off checks for things to import.
	(with-temporary (transpiler-import-from-environment? tr) nil
	  (transpiler-expand-and-generate-code tr forms))))

(defun transpiler-sighten (tr x)
  (when (transpiler-lambda-export? tr)
	(setf *exported-lambdas* t))
  (let tmp (transpiler-preexpand tr (transpiler-simple-expand tr x))
	; Do an expression expand to collect the names of required
	; functions and variables. It is done again later when all
	; definitions are visible.
	(transpiler-expression-expand tr tmp)
	tmp))

(defun transpiler-sighten-files (tr files)
  (mapcan (fn (format t "(LOAD \"~A\")~%" _)
        	  (transpiler-sighten tr (read-file-all _)))
		  files))
