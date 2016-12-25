(defun funinfo-add-local-function-args (fi fun-name args)
  (& (assoc fun-name (funinfo-local-function-args fi) :test #'eq)
     (error "Local function arguments for ~A are already set." fun-name))
  (acons! fun-name args (funinfo-local-function-args fi)))

(defun funinfo-get-local-function-args (fi fun-name)
  (!? (funinfo-find fi fun-name)
      (assoc-value fun-name (funinfo-local-function-args !) :test #'eq)))
