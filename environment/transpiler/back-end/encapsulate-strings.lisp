; tré – Copyright (c) 2008–2013,2015 Sven Michael Klose <pixel@copei.de>

(define-tree-filter encapsulate-strings (x)
  (string? x)         `(%%string ,x)
  (| (quote? x)
     (%%native? x)
     (%%comment? x))  x)
