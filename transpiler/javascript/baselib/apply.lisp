;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun apply (fun &rest lst)
  (let args (%nconc (butlast lst)
				    (car (last lst)))
    (fun.apply nil
	  (list-array
	    (aif fun.tre-args
             (argument-expand-values fun ! args)
			 args)))))
