;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-encapsulate-strings (x)
  (string? x)       `(%%string ,x)
  (| (%quote? x)
     (%%native? x)) x)
