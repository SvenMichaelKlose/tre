;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-encapsulate-strings (x)
  (string? x)
    `(%transpiler-string ,x)
  (or (%quote? x)
	  (%transpiler-native? x))
    x)
