;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-expand-literal-characters (x)
  (character? x) `(code-char ,(char-code x)))
