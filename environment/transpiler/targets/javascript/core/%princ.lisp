(defnative %princ (txt &optional (str *standard-output*))
  (~> (stream-fun-out str) txt str)
  txt)
