;;;;;; tré – Copyright (c) 2011,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate btoa atob)
(declare-cps-exception base64-encode base64-decode)

(defun base64-encode (x)
  (btoa x))

(defun base64-decode (x)
  (atob x))
