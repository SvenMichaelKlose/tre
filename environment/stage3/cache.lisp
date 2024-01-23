(defmacro cache (place val)
  `(| ,place
      (= ,place ,val)))
