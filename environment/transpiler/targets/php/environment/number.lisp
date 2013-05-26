;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate is_int is_float)

(defun integer? (x)
  (is_int x))

(defun %number? (x)
  (| (is_int x)
     (is_float x)))

(defun number (x)
  (%%native "(float)$" x))

(defun number-integer (x)
  (%%native "(int)$" x))
