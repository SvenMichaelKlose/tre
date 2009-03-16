;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;;;; LAMBDA EXPANSION

(defun transpiler-lambda-expand (tr x)
  (with ((new-x exported-closures)
		     (lambda-expand x
						    (transpiler-lambda-export? tr)))
    (dolist (i exported-closures new-x)
	  (transpiler-add-exported-closure tr i))))
