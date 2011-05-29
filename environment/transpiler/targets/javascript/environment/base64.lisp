;;;;;; TRE
;;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(dont-obfuscate btoa atob)

(defun base64-encode (x)
  (btoa x))

(defun base64-decode (x)
  (atob x))
