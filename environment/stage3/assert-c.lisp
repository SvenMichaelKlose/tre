(defmacro assert (x &optional (txt "") &rest args)
  (when *assert?*
    (make-assertion x txt args)))
