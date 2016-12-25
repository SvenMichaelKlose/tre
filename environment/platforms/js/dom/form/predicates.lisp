(defun form-element? (x)
  (& (element? x)
     (x.tag-name? '("input" "textarea" "select" "option" "radiobox"))))

(defun submit-button? (x)
  (& (element? x)
     (x.attribute-value? "type" "submit")))

(defun named-form-element? (x)
  (x.tag-name? '("form" "select" "input" "textarea")))
