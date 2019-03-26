;;;;; tré – Copyright (c) 2009–2010,2012 Sven Michael Klose <pixel@copei.de>

(defun form? (x)
  (& (element? x)
     (x.has-tag-name? "form")))

(defun form-element? (x)
  (& (element? x)
     (x.has-tag-name? '("input" "textarea" "select" "option" "radiobox"))))

(defun submit-button? (x)
  (& (element? x)
     (x.attribute-value? "type" "submit")))

(defun named-form-element? (x)
  (x.has-tag-name? '("form" "select" "input" "textarea")))
