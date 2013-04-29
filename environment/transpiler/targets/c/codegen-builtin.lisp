;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

,`(progn
    ,@(macroexpand (mapcar [let n (make-symbol (c-builtin-name _))
                             (unless (expander-has-macro? 'c-codegen _)
                               `(define-c-std-macro ,_ (&rest x)
                                  `(,n ,,(compiled-list x))))]
                           (c-builtin-names))))
