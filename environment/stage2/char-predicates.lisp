(defmacro def-rest-predicate (name iter args test-expr)
  (with-gensym x
    `(fn ,name (&rest ,x ,@args)
       (@ (,iter ,x t)
         (| ,test-expr
            (return nil))))))

(functional charrange?)
(fn charrange? (x start end)
  (range? (char-code x) (char-code start) (char-code end)))

(functional lower-case?)
(def-rest-predicate lower-case? c ()
  (charrange? c #\a #\z))

(functional upper-case?)
(def-rest-predicate upper-case? c ()
  (charrange? c #\A #\Z))

(functional alpha-char?)
(def-rest-predicate alpha-char? c ()
  (| (lower-case? c)
     (upper-case? c)))

(functional decimal-digit?)
(fn decimal-digit? (x)
  (charrange? x #\0 #\9))

(fn %nondecimal-digit? (x start base)
  (charrange? x start (code-char (+ (char-code start) (- base 10)))))

(functional nondecimal-digit?)
(fn nondecimal-digit? (x &key (base 10))
  (& (< 10 base)
     (| (%nondecimal-digit? x #\a base)
        (%nondecimal-digit? x #\A base))))

(functional digit-char?)
(fn digit-char? (c &key (base 10))
  (& (character? c)
     (| (decimal-digit? c)
        (nondecimal-digit? c :base base))))

(functional hex-digit-char?)
(fn hex-digit-char? (x)
  (| (digit-char? x)
     (& (character>= x #\A) (character<= x #\F))
     (& (character>= x #\a) (character<= x #\f))))

(functional alphanumeric?)
(def-rest-predicate alphanumeric? c ()
  (| (alpha-char? c)
     (digit-char? c)))

(functional whitespace?)
(fn whitespace? (x)
  (& (character? x)
     (< (char-code x) 33)
     (>= (char-code x) 0)))

(functional control-char?)
(fn control-char? (x)
  (character< x (code-char 32)))
