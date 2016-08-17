; tré – Copyright (c) 2009–2010,2012–2016 Sven Michael Klose <pixel@copei.de>

(defun form-action-get (x)
  ((x.get "<form").read-attribute "action"))

(defun form-input-element? (x)
  (& (not (submit-button? x))
     (x.has-tag-name? '("input" "textarea" "select"))))

(defun form-get-input-elements (x)
  (+ (remove-if-not #'form-input-element? (x.get-list "input"))
     (x.get-list "textarea")
     (x.get-list "select")))

(defun form-get-submit-buttons (x)
  (remove-if-not #'submit-button? (form-get-input-elements x)))

(defun get-submit-button (form)
  (@ (elm (form.get-list "input"))
	(& (elm.attribute-value? "type" "submit")
	   (return elm))))

(defun form-rename (x name)
  ((x.get "<form").set-name name))
