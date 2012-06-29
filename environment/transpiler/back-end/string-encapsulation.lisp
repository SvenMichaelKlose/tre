;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-encapsulate-strings (x)
  (string? x)
    `(%transpiler-string ,x)
  (| (%quote? x)
     (%transpiler-native? x))
    x)
