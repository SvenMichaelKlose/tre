;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun transpiler-expand-characters (x)
  (if
	(characterp x)
	  `(code-char ,(char-code x))
    (consp x)
	  (traverse #'transpiler-expand-characters x)
	x))

(defun c-expand-literals (x)
  (if
	(characterp x)
	  `(trechar_get ,(char-code x))
;	(numberp x)
;	  `(trenumber_get ,x)
	(stringp x)
	  `(trestring_get ,x)
    (consp x)
	  (traverse #'c-expand-literals x)
	x))
