; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(define-tree-filter expand-literal-characters (x)
  (character? x) `(code-char ,(char-code x)))
