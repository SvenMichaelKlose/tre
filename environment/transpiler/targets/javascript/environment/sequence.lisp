;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-obfuscate length)

(defun length (x)
  (if x
      (if (cons? x)
	      (%list-length x)
	      x.length)
      0))
