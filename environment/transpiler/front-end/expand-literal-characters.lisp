;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter transpiler-expand-literal-characters (x)
  (character? x) (? (eq 'c (transpiler-name *transpiler*))
                    `(trenumber_builtin_code_char ,(compiled-list (list (char-code x))))
                    `(code-char ,(char-code x))))
