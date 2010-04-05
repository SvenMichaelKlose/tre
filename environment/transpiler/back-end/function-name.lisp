;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun compiled-function-name (x)
  (if (%transpiler-native? x)
	  x
      ($ 'compiled_ x)))
