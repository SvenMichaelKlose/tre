(defmacro cache (val place)
  `(| ,place
      (= ,place ,val)))
