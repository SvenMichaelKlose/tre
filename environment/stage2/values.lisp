(defun values (&rest vals)
  (. 'values vals))

(defun values? (x)
  (& (cons? x)
     (eq 'values x.)))
