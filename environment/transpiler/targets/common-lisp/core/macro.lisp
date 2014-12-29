; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin macro? (x)
  (cl:rassoc x *macros* :test #'eq))

(defun env-macros ()
  (symbol-value (make-symbol "*MACROS*" "TRE")))

(defbuiltin %%macrocall (x)
  (alet (cdr (assoc x. (env-macros) :test #'eq))
    (apply .! (argument-expand-values x. !. .x))))

(defbuiltin %%macro? (x)
  (& (cons? x)
     (symbol? x.)
     (alet (env-macros)
       (& (cons? !)
          (assoc x. ! :test #'eq)))))

(defvar *macroexpand-hook* nil)

(defbuiltin macroexpand-1 (x)
  (!? (symbol-value (make-symbol "*MACROEXPAND-HOOK*" "TRE"))
      (apply ! (list x))
      x))

(defbuiltin macroexpand (x)
  (with (f #'((old x)
               (? (equal old x)
                  x
                  (macroexpand x))))
    (f x (macroexpand-1 x))))
