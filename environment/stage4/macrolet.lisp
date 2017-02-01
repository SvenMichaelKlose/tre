(defmacro macrolet ((&body macros) &body body)
  (let e (define-expander 'macrolet)
    (@ (i macros (expander-expand e `(progn ,@body)))
      (set-expander-macro e i. .i. (eval `#'(,.i. ,@..i))))))
