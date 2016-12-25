(defun form-action-get (x)
  ((x.get "<form").read-attribute "action"))

(defun form-input-element? (x)
  (& (not (submit-button? x))
     (x.tag-name? '("input" "textarea" "select"))))

(defun form-get-input-elements (x)
  (+ (remove-if-not #'form-input-element? (x.get-list "input"))
     (x.get-list "textarea")
     (x.get-list "select")))

(defun form-get-submit-buttons (x)
  ((x.get "<.form").get "input[type=submit]"))

(defun get-submit-button (form)
  (@ (elm (form.get-list "input"))
	(& (elm.attribute-value? "type" "submit")
	   (return elm))))

(defun form-rename (x name)
  ((x.get "<form").set-name name))
