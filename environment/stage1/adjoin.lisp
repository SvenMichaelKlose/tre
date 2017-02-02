(functional adjoin)

(defun adjoin (obj lst &rest args)
  (? (apply #'member obj lst args)
     lst
     (. obj lst)))

(defmacro adjoin! (obj &rest place)
  `(= ,place. (adjoin ,obj ,@place)))
