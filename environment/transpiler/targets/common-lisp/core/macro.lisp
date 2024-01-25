(fn env-macros ()
  (symbol-value (tre-symbol '*macros*)))

(defbuiltin macro? (x)
  (CL:RASSOC x (env-macros) :TEST #'eq))

(defbuiltin %%macrocall (x)
  (!= (cdr (assoc x. (env-macros) :test #'eq))
    (*> .! (argument-expand-values x. !.. .x))))

(defbuiltin %%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (!= (env-macros)
       (& (cons? !)
          (assoc x. ! :test #'eq)))))

(var *macroexpand* nil)

(defbuiltin macroexpand-1 (x)
  (!? (symbol-value (tre-symbol '*macroexpand*))
      (*> ! (list x))
      x))

(defbuiltin macroexpand (x)
  (with (f #'((old x)
               (? (equal old x)
                  x
                  (macroexpand x))))
    (f x (macroexpand-1 x))))
