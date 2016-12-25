(defbuiltin %error (msg)
  (cl:break (neutralize-format-string msg)))
