(const *values-magic* ($ 'values- ,`',(gensym)))

(fn values (&rest vals)
  (. *values-magic* vals))

(fn values? (x)
  (& (cons? x)
     (eq *values-magic* x.)))
