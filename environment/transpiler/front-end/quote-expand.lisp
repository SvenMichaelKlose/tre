(fn quote-expand (x)
  (with (any-quasiquote?  [| (quasiquote? _)
                             (quasiquote-splice? _)]
         atomic  [? (constant-literal? _)
                    _
                    `(quote ,_)]
         static  [? (atom _)
                    (atomic _)
                    `(. ,(static _.)
                        ,(static ._))]
         qq      [? (any-quasiquote? (cadr _.))
                    `(. ,(backq (cadr _.))
                        ,(backq ._))
                    `(. ,(cadr _.)
                        ,(backq ._))]
         qqs     [? (any-quasiquote? (cadr _.))
                    (error "Illegal ~A as argument to ,@ (QUASIQUOTE-SPLICE)." (cadr _.))
                    (with-gensym g
                      ; TODO: Make TRANSPILER-MACROEXPAND work and use LET.
                      (compiler-macroexpand
                        `(#'((,g)
                              (append (? (json-object? ,g)
                                         (props-klist ,g)
                                         ,g)
                                ,(backq ._)))
                           ,(cadr _.))))]
         backq   [?
                   (atom _)             (atomic _)
                   (pcase _.
                     atom               `(. ,(atomic _.)
                                            ,(backq ._))
                     quasiquote?        (qq _)
                     quasiquote-splice? (qqs _)
                     `(. ,(backq _.)
                         ,(backq ._)))]
         disp    [pcase _
                   quote?     (static ._.)
                   backquote? (backq ._.)
                   _]
         walk    [? (atom _)
                    (disp _)
                    (. (walk (disp _.))
                       (walk ._))])
    (car (walk (list x)))))
