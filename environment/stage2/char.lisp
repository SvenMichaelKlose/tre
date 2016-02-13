; tré – Copyright (c) 2005–2006,2008–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(functional char-upcase char-downcase char-code code-char)

(defun char-upcase (c)
  (? (lower-case? c)
     (character- (character+ c #\A) #\a)
     c))

(defun char-downcase (c)
  (? (upper-case? c)
     (character- (character+ c #\a) #\A)
     c))
