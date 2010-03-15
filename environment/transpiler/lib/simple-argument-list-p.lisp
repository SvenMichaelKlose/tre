;;;;; TRE transpiler
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun simple-argument-list? (x)
  (if x
      (not (member-if (fn or (consp _)
	                         (argument-keyword? _))
				      x))
	  t))
