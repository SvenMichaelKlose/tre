(defmacro ++! (place &optional (n 1))
  `(= ,place (number+ ,place ,n)))

(defmacro --! (place &optional (n 1))
  `(= ,place (- ,place ,n)))

(defmacro integer++! (place &optional (n 1))
  `(= ,place (integer+ ,place ,n)))

(defmacro integer--! (place &optional (n 1))
  `(= ,place (integer- ,place ,n)))
