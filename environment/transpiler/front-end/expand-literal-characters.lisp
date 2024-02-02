(define-tree-filter2 expand-literal-characters (x)
  (character? x)
    `(code-char ,(char-code x)))
