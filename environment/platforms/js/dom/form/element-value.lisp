(defun (= attribute-value) (val x)
  (x.write-attribute "value" x))

(defun has-alternative-value? (x)
  (x.has-attribute? "alternative-value"))

(defun alternative-value (x)
  (x.read-attribute "alternative-value"))

(defun (= alternative-value) (val x)
  (x.write-attribute "alternative-value" val))

(defun element-value (x)
  (?
    (x.is? "input[type=text], input[type=password]")
      (| (has-alternative-value? x) ; TODO: Remove alternative-value thingy.
         x.value)
	(x.is? "textarea")
      x.text
	(x.is? "select")
      (form-select-get-selected-option-value x)
    x.text-content))

(defun set-element-value-attribute (x val)
  (? (has-alternative-value? x)
     (= (attribute-value x) val)
     (= x.value val)))

(defun (= element-value) (val x)
  (?
	(input-element-w/-value-attribute? x)  (set-element-value-attribute x val)
	(x.is? "textarea")           (= x.text val)
    {(x.remove-children)
	 (x.add-text val)})
  val)

(defun get-named-elements (x)
  (with-queue q
	(x.walk [& (element? _)
			   (_.has-name-attribute?)
			   (enqueue q _)
			   nil])
	(queue-list q)))
