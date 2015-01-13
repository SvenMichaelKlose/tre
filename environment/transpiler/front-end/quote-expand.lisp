; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@copei.de>

(defun quote-expand (x)
  (with (atomic [? (constant-literal? _)
                   _
                   `(quote ,_)]
         static [? (atom _)
                   (atomic _)
                   `(. ,(static _.)
                       ,(static ._))]
         qq     [? (any-quasiquote? (cadr _.))
                   `(. ,(backq (cadr _.))
                       ,(backq ._))
                   `(. ,(cadr _.)
                       ,(backq ._))]
         qqs    [? (any-quasiquote? (cadr _.))
                   (error "Illegal ~A as argument to ,@ (QUASIQUOTE-SPLICE)."
                          (cadr _.))
                   `(append ,(cadr _.) ,(backq ._))]
         backq  [?
                  (atom _)                (atomic _)
                  (atom _.)               `(. ,(atomic _.)
                                              ,(backq ._))
                  (quasiquote? _.)        (qq _)
                  (quasiquote-splice? _.) (qqs _)
                  `(. ,(backq _.)
                      ,(backq ._))]
         disp   [?
                  (quote? _)     (static ._.)
                  (backquote? _) (backq ._.)
                  _])
    (tree-walk x :ascending #'disp)))
