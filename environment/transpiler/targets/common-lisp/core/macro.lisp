(fn env-macros ()
  (symbol-value (tre-symbol '*macros*)))

(defbuiltin macro? (x)
  (cl:rassoc x (env-macros) :test #'eq))

(defbuiltin %%macrocall (x)
  (alet (cdr (assoc x. (env-macros) :test #'eq))
    (apply .! (argument-expand-values x. !.. .x))))

(defbuiltin %%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (alet (env-macros)
       (& (cons? !)
          (assoc x. ! :test #'eq)))))

(var *macroexpand* nil)

(defbuiltin macroexpand-1 (x)
  (!? (symbol-value (tre-symbol '*macroexpand*))
      (apply ! (list x))
      x))

(defbuiltin macroexpand (x)
  (with (f #'((old x)
               (? (equal old x)
                  x
                  (macroexpand x))))
    (f x (macroexpand-1 x))))
