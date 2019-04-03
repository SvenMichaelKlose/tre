(define-tree-filter expand-literal-characters (x)
  (character? x)  `(code-char ,(char-code x)))
