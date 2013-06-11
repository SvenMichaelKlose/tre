;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

,`(progn
    ,@(macroexpand (mapcar [`(define-c-macro ,_ (&rest x)
                               `(,(make-symbol (c-builtin-name _)) ,,@x))]
                           (c-builtin-names))))
