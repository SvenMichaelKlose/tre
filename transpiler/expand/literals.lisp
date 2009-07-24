;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-characters (x)
  (if
	(characterp x)
	  `(code-char ,(char-code x))
    (consp x)
	  (cons (transpiler-expand-characters x.)
		    (transpiler-expand-characters .x))
	x))
