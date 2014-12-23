; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin quit (&optional exit-code)
  (sb-ext:quit :unix-status exit-code))

(defbuiltin nanotime () 0)
