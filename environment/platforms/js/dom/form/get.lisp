;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun form-action-get (x)
  ((ancestor-or-self-form-element x).read-attribute "action"))

(defun form-input-element? (x)
  (& (not (submit-button? x))
     (x.has-tag-name? (list "input" "textarea" "select"))))

(defun form-get-input-elements (x)
  (+ (find-all-if #'form-input-element? (get-input-elements x))
     (get-textarea-elements x)
     (get-select-elements x)))

(defun form-get-submit-buttons (x)
  (find-all-if #'submit-button?  (get-input-elements x)))

(defun get-submit-button (form)
  (do-elements-by-tag-name (elm form "input")
	(& (elm.attribute-value? "type" "submit")
	   (return elm))))

(defun form-rename (x name)
  ((ancestor-or-self-form-element x).set-name name))
