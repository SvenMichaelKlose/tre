;;;;; tré – Copyright (c) 2009,2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate encode-u-r-i-component decode-u-r-i-component)

(defun unicode-utf8 (x)
  (unescape (encode-u-r-i-component x)))

(defun utf8-unicode (x)
  (decode-u-r-i-component (escape x)))
