(functional character>= character<= char-upcase char-downcase char-code code-char)

(defun character>= (&rest x)
    (apply #'>= (@ #'char-code x)))

(defun character<= (&rest x)
    (apply #'<= (@ #'char-code x)))

(defun char-upcase (c)
  (? (lower-case? c)
     (code-char (- (+ (char-code c) (char-code #\A)) (char-code #\a)))
     c))

(defun char-downcase (c)
  (? (upper-case? c)
     (code-char (- (+ (char-code c) (char-code #\a)) (char-code #\A)))
     c))
