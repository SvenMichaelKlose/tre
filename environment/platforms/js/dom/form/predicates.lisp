(defun form-element? (x)
  (& (element? x)
     (x.is? "input, textarea, select, option, radiobox")))

(defun submit-button? (x)
  (& (element? x)
     (x.is? "[type=submit]")))
