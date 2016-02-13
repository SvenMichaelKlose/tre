; tré – Copyright (c) 2005–2006,2008–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(functional character>= character<=
            char-upcase char-downcase
            char-code code-char)

(defun character>= (&rest x)
  (apply #'>= (@ #'char-code x)))

(defun character<= (&rest x)
  (apply #'<= (@ #'char-code x)))

(defun char-upcase (c)
  (? (lower-case? c)
     (character- (character+ c #\A) #\a)
     c))

(defun char-downcase (c)
  (? (upper-case? c)
     (character- (character+ c #\a) #\A)
     c))
