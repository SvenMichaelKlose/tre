(functional character>= character<= char-upcase char-downcase)

(fn character>= (&rest x)
  (apply #'>= (@ #'char-code x)))

(fn character<= (&rest x)
  (apply #'<= (@ #'char-code x)))

(fn char-upcase (c)
  (? (lower-case? c)
     (code-char (- (+ (char-code c) (char-code #\A)) (char-code #\a)))
     c))

(fn char-downcase (c)
  (? (upper-case? c)
     (code-char (- (+ (char-code c) (char-code #\a)) (char-code #\A)))
     c))
