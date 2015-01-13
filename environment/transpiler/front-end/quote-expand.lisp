; tré – Copyright (c) 2006–2015 Sven Michael Klose <pixel@copei.de>

(defun quote-expand (x)
  (with (atomic [? (constant-literal? _)
                   _
                   `(quote ,_)]
         quot   [? (atom _)
                   (atomic _)
                   `(. ,(quot _.)
                       ,(quot ._))]
         qq     [? (any-quasiquote? (cadr _.))
                   `(. ,(conv (cadr _.))
                       ,(conv ._))
                   `(. ,(cadr _.)
                       ,(conv ._))]
         qs     [? (any-quasiquote? (cadr _.))
                   (error "~A in QUASIQUOTE-SPLICE (or ',@' for short)."
                          (cadr _.))
                   (!? (conv ._)
                       `(append ,(cadr _.) ,(conv ._))
                       (cadr _.))]
         conv   [?
                  (atom _)                (atomic _)
                  (atom _.)               `(. ,(atomic _.)
                                              ,(conv ._))
                  (quasiquote? _.)        (qq _)
                  (quasiquote-splice? _.) (qs _)
                  `(. ,(conv _.)
                      ,(conv ._))])
    (tree-walk x
               :ascending [?
                            (quote? _)     (quot ._.)
                            (backquote? _) (conv ._.)
                            _])))
