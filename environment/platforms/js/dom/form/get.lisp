(defun form-action-get (x)
  ((x.get "<form").read-attribute "action"))

(defun form-input-element? (x)
  (& (not (submit-button? x))
     (x.is? "input, textarea, select")))

(defun form-get-input-elements (x)
  (+ (remove-if-not #'form-input-element? (x.get-list "input"))
     (x.get-list "textarea")
     (x.get-list "select")))
