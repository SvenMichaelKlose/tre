;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

,`(progn
    ,@(macroexpand (mapcar [unless (expander-has-macro? 'c-codegen _)
                             `(define-c-std-macro ,_ (&rest x)
                                `(,(make-symbol (c-builtin-name _)) ,,(compiled-list x)))]
                           (c-builtin-names))))
