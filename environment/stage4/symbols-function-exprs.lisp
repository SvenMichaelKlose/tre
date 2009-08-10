(defun symbols-function-exprs (x)
  (mapcar (fn `(function ,_))
		  x))
