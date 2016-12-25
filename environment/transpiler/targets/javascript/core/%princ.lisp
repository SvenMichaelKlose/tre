(defnative %princ (txt &optional (str *standard-output*))
  (funcall (stream-fun-out str) txt str)
  txt)
