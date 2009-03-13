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
      `(trechar_get (%no-expex ,(char-code x)))
    (numberp x)
      `(trenumber_get (%no-expex ,x))
    (stringp x)
      `(trestring_get (%no-expex ,x))
  x))
