; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defun env-macros ()
  (symbol-value (make-symbol "*MACROS*" "TRE")))

(defbuiltin macro? (x)
  (cl:rassoc x (env-macros) :test #'eq))

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
