;;;;; tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>

(functional char-upcase char-downcase char-code code-char)

(defun char-upcase (c)
  (? (lower-case? c)
     (character+ c (character- #\A #\a))
     c))

(defun char-downcase (c)
  (? (upper-case? c)
     (character+ c (character- #\a #\A))
     c))
