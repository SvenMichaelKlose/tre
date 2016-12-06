; tré – Copyright (c) 2008–2013,2015–2016 Sven Michael Klose <pixel@copei.de>

,`{,@(macroexpand (@ [`(define-c-macro ,_ (&rest x)
                         `(%%native ,(make-symbol (c-builtin-name _)) ,,(c-list x)))]
                     (c-builtin-names)))}
