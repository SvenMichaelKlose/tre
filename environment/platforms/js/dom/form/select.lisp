(defun form-select? (x)
  (& (element? x)
     (x.is? "select")))

(defun form-select-get-options (x)
  ((x.get "<select").get-list "option"))

(defun form-select-get-select-names (x)
  (@ [_.get-name] (x.get-list "select")))

(defun form-select-get-by-name (x name)
  (adolist ((x.get-list "select"))
    (& (!.attribute-value? "name" name)
       (return !))))

(defun form-select-get-option-by-value (x name)
  (do-children (i x)
    (& (i.attribute-value? "value" name)
       (return i))))

(defun form-select-unselect-options (x)
  (do-children (i x x)
    (i.remove-attribute "selected")))

(defun form-select-select-option (x)
  (when x
    (form-select-unselect-options x.parent-node)
    (= x.selected t)
    (x.write-attribute "selected" "1"))
  x)

(defun form-select-select-option-by-value (x n)
  (form-select-select-option (form-select-get-option-by-value x n))
  x)

(defun form-select-get-selected-option (x)
  (do-children (i x)
	(& i.selected
	   (return i))))

(defun form-select-get-selected-option-text (x)
  (form-select-get-selected-option x).text-content)

(defun form-select-get-selected-option-value (x)
  (let-when o (form-select-get-selected-option x)
	(o.read-attribute "value")))

(defun form-select-add-option (x txt &optional (attrs nil))
  (with (select-element  (x.get "<select")
		 option-element  (new *element "option" attrs))
	(option-element.add-text txt)
	(select-element.add option-element)))

(defun form-select-rename-option (option-element txt)
  (option-element.remove-children)
  (option-element.add-text txt))

(defun form-select-option-texts-to-string-lists (options)
  (when options
    (let option options.
      (. (string-list option.text-content)
         (form-select-option-texts-to-string-lists .options)))))

(defun form-select-add-string-list-options (select-element options)
  (when options
	(let option-element (new *element "option")
	  (option-element.add-text (list-string options.))
	  (select-element.add option-element))
	(form-select-add-string-list-options select-element .options)))

(defun form-select-sort (x)
  (with (select-element  (x.get "<select")
		 option-list     (form-select-option-texts-to-string-lists (form-select-get-options x))
		 sorted-options  (sort option-list :test #'<=-list))
	(select-element.remove-children)
	(form-select-add-string-list-options select-element sorted-options)))
