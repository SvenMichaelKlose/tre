;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun transpiler-splice (x)
  (mapcan (fn (if (%transpiler-splice? _)
			   	  ._
				  (list _)))
		  x))
