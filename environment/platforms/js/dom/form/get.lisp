(fn form-action-get (x)
  ((x.get "<form").read-attribute "action"))

(fn form-input-element? (x)     ; TODO: Move to predicates.lisp.
  (& (not (submit-button? x))
     (x.is? "input, textarea, select")))

(fn form-get-input-elements (x)
  (+ (remove-if-not #'form-input-element? (x.get-list "input"))
     (x.get-list "textarea")
     (x.get-list "select")))
