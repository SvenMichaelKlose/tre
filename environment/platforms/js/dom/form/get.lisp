(fn form-action-get (x)
  ((x.get "<form").read-attribute "action"))

(fn form-get-elements (x)
  (x.get-list "input, textarea, select"))

(fn form-get-input-elements (x)
  (remove-if #'submit-button? (form-get-elements x)))

(fn form-get-text-elements (x)
  (remove-if-not #'form-text-element? (form-get-elements x)))
