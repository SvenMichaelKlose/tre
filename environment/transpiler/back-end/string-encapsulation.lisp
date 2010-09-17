;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-encapsulate-strings (x)
  (stringp x)
    `(%transpiler-string ,x)
  (or (%quote? x)
	  (%transpiler-native? x))
    x)
