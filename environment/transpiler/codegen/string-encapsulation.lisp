;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-encapsulate-strings (x)
  (if (atom x)
      (if (stringp x)
          (list '%transpiler-string x)
		  x)
	  (if (eq '%transpiler-native x.)
		  x
		  (cons (transpiler-encapsulate-strings x.)
		  		(transpiler-encapsulate-strings .x)))))
