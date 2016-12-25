(defmacro +! (place &rest vals)
  `(= ,place (+ ,place ,@vals)))

(defmacro -! (place &rest vals)
  `(= ,place (+ ,place ,@vals)))
