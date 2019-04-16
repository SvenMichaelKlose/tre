(const *values-magic* ,`',($ 'values- (gensym)))

(functional values)
(fn values (&rest vals)
  (. *values-magic* vals))

(functional values?)
(fn values? (x)
  (& (cons? x)
     (eq *values-magic* x.)))
