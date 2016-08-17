;;;;; tré – Copyright (c) 2010–2012 Sven Michael Klose <pixel@copei.de>

(defun (= attribute-value) (val x)
  (x.write-attribute "value" x))

(defun has-alternative-value? (x)
  (x.has-attribute? "alternative-value"))

(defun alternative-value (x)
  (x.read-attribute "alternative-value"))

(defun (= alternative-value) (val x)
  (x.write-attribute "alternative-value" val))

(defun input-element-w/-value-attribute? (x)
  (& (x.tag-name? "input")
	 (| (x.attribute-value? "type" "text")
	    (x.attribute-value? "type" "password"))))

(defun element-value (x)
  (?
	(input-element-w/-value-attribute? x)  (| (has-alternative-value? x)
                                              x.value)
	(x.tag-name? "textarea")           x.text
	(x.tag-name? "select")             (form-select-get-selected-option-value x)
    x.text-content))

(defun set-element-value-attribute (x val)
  (? (has-alternative-value? x)
     (= (attribute-value x) val)
     (= x.value val)))

(defun (= element-value) (val x)
  (?
	(input-element-w/-value-attribute? x)  (set-element-value-attribute x val)
	(x.tag-name? "textarea")           (= x.text val)
    (progn
	  (x.remove-children)
	  (x.add-text val)))
  val)

(defun get-named-elements (x)
  (with-queue q
	(x.walk [& (element? _)
			   (_.has-name-attribute?)
			   (enqueue q _)
			   nil])
	(queue-list q)))
