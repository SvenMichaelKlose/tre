(defbuiltin %error (msg)
  (CL:BREAK (neutralize-format-string msg)))
