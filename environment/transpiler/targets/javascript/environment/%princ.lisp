; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defnative %princ (txt &optional (str *standard-output*))
  (funcall (stream-fun-out str) txt str)
  txt)
