(defmacro toggle (place)
  `(= ,place (not ,place)))
