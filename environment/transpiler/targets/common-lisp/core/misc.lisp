(defbuiltin quit (&optional exit-code)
  (sb-ext:quit :unix-status exit-code))
