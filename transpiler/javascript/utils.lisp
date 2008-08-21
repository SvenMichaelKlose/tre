;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Utilities
;;;;;
;;;;; Should be moved to the environment.

(defun read-many (str)
  (with (x nil)
	(while (not (end-of-file str)) (reverse x)
	  (awhen (read str)
		(push ! x)))))
