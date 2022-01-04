(var *language* :en)
(var *fallback-language* :en)
,(unless (transpiler-defined-variable *transpiler* '*l10n-text-filter*)
  '(var *l10n-text-filter* #'identity))

(defmacro lang (&rest args)
  (? (== 2 (length args))
     .args.
     (with (defs     (group args 2)
            default  (assoc *fallback-language* defs))
       `(funcall *l10n-text-filter* (case *language* :test #'eq
                                      ,@(mapcan [. (make-keyword _.) ._]
                                                (remove default defs))
                                      ,.default.)))))

(fn translate (x)
  (? (string? x)
     x
     (| (assoc-value *language* (@ [. (make-keyword _.) ._] x))
        (cdar x))))

(defmacro singular-plural (num consequence fallback)
  `(? (== 1 ,num)
      ,consequence
      ,fallback))

(fn switch-language (to)
  (= *language* (| (find to *available-languages*)
                   *fallback-language*)))
