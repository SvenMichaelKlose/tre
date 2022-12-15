(fn form-select? (x) ; TODO: Remove.
  (& (element? x)
     (x.is? "select")))

(fn form-select-get-options (x) ; TODO: Remove.
  ((x.get "<select").get-list "option"))

(fn form-select-get-select-names (x) ; TODO: Remove.
  (@ [_.get-name] (x.get-list "select")))

(fn form-select-get-by-name (x name) ; TODO: Remove.
  (@ (i (x.get-list "select"))
    (& (i.attribute-value? "name" name)
       (return i))))

(fn form-select-get-option-by-value (x name) ; TODO: Remove.
  (do-children (i x)
    (& (i.attribute-value? "value" name)
       (return i))))

(fn form-select-unselect-options (x)
  (do-children (i x x)
    (i.remove-attribute "selected")))

(fn form-select-select-option (x)
  (when x
    (form-select-unselect-options x.parent-node)
    (= x.selected t)
    (x.write-attribute "selected" "1"))
  x)

(fn form-select-select-option-by-value (x n)
  (form-select-select-option (form-select-get-option-by-value x n))
  x)

(fn form-select-get-selected-option (x)
  (do-children (i x)
    (& i.selected
       (return i))))

(fn form-select-get-selected-option-text (x)
  (form-select-get-selected-option x).text-content)

(fn form-select-get-selected-option-value (x)
  (let-when o (form-select-get-selected-option x)
    (o.attr "value")))

(fn form-select-add-option (x txt &optional (attrs nil))
  (with (select-element  (x.get "<select")
         option-element  (make-extended-element "option" attrs))
    (option-element.add-text txt)
    (select-element.add option-element)))

(fn form-select-rename-option (option-element txt)
  (option-element.remove-children)
  (option-element.add-text txt))

(fn form-select-option-texts-to-string-lists (options)
  (when options
    (let option options.
      (. (string-list option.text-content)
         (form-select-option-texts-to-string-lists .options)))))

(fn form-select-add-string-list-options (select-element options)
  (when options
    (let option-element (make-extended-element "option")
      (option-element.add-text (list-string options.))
      (select-element.add option-element))
    (form-select-add-string-list-options select-element .options)))

(fn form-select-sort (x)
  (with (select-element  (x.get "<select")
         option-list     (form-select-option-texts-to-string-lists (form-select-get-options x))
         sorted-options  (sort option-list :test #'<=-list)) ; TODO: Fix me.
    (select-element.remove-children)
    (form-select-add-string-list-options select-element sorted-options)))
