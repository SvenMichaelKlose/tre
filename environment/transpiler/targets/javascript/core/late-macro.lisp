(= *standard-macro-expander* (define-expander 'standard-macros))
(set-expander-macros *standard-macro-expander* *macros*)

(fn %%macro? (x)
  (expander-has-macro? *standard-macro-expander* x.))

(fn %%macrocall (x)
  (funcall (expander-call *standard-macro-expander*) x))

(= *macroexpand-backquote* #'%macroexpand-backquote)
