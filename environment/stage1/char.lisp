(functional character>= character<= char-upcase char-downcase number-digit
            digit-number charrange? lower-case? upper-case? alpha-char?
            decimal-digit? nondecimal-digit? digit? hex-digit? alphanumeric?
            whitespace? control-char?)

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

(fn number-digit (x)
  (code-char (? (< x 10)
                (+ (char-code #\0) x)
                (+ (char-code #\a) -10 x))))

(fn digit-number (x)
  (- (char-code x) (char-code #\0)))

(fn charrange? (x start end)
  (range? (char-code x) (char-code start) (char-code end)))

(fn lower-case? (x)
  (charrange? x #\a #\z))

(fn upper-case? (x)
  (charrange? x #\A #\Z))

(fn alpha-char? (x)
  (| (lower-case? x)
     (upper-case? x)))

(fn decimal-digit? (x)
  (charrange? x #\0 #\9))

(fn %nondecimal-digit? (x start base)
  (charrange? x start (code-char (+ (char-code start) (- base 10)))))

(fn nondecimal-digit? (x &key (base 10))
  (& (< 10 base)
     (| (%nondecimal-digit? x #\a base)
        (%nondecimal-digit? x #\A base))))

(fn digit? (c &key (base 10))
  (& (character? c)
     (| (decimal-digit? c)
        (nondecimal-digit? c :base base))))

(fn hex-digit? (x)
  (| (digit? x)
     (& (character>= x #\A) (character<= x #\F))
     (& (character>= x #\a) (character<= x #\f))))

(fn alphanumeric? (x)
  (| (alpha-char? x)
     (digit? x)))

(fn whitespace? (x)
  (& (character? x)
     (< (char-code x) 33)
     (>= (char-code x) 0)))

(fn control-char? (x)
  (character< x (code-char 32)))
