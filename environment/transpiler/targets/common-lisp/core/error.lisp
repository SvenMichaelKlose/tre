; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defbuiltin %error (msg)
  (cl:break (neutralize-format-string msg)))
