(var *lml-expander* (define-expander 'LML))

(defmacro define-lml-macro (&rest x)
  (print-definition `(define-lml-macro ,x. ,.x.))
  `(def-expander-macro *lml-expander* ,@x))

(fn lml-expand (x)
  (expander-expand *lml-expander* x))
