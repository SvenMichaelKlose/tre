(fn (= attribute-value) (val x)
  (x.write-attribute "value" x))

(fn element-value (x)
  (?
    (x.is? "input[type=text], input[type=password], textarea")
      x.value
	(x.is? "select")
      (form-select-get-selected-option-value x)
    x.text-content))    ; TODO: Should be x.value nowadays.

(fn (= element-value) (val x)
  (= x.value val))
