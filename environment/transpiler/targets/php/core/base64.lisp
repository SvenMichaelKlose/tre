;;;;;; TRE
;;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(dont-obfuscate base64_encode base64_decode)

(defun base64-encode (x)
  (base64_encode x))

(defun base64-decode (x)
  (base64_decode x))