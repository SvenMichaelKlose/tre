;;;;; TRE transpiler
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun simple-argument-list? (x)
  (? x
     (not (member-if (fn or (cons? _)
	                        (argument-keyword? _))
				     x))
	 t))
