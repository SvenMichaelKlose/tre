(functional lower-case? upper-case? alpha-char? digit-char? alphanumeric?)

(defmacro def-rest-predicate (name iter args test-expr)
  (with-gensym x
    `(fn ,name (&rest ,x ,@args)
       (@ (,iter ,x t)
         (| ,test-expr
            (return nil))))))

(fn charrange? (x start end)
  (range? (char-code x) (char-code start) (char-code end)))

(def-rest-predicate lower-case? c ()
  (charrange? c #\a #\z))

(def-rest-predicate upper-case? c ()
  (charrange? c #\A #\Z))

(def-rest-predicate alpha-char? c ()
  (| (lower-case? c)
     (upper-case? c)))

(fn decimal-digit? (x)
  (charrange? x #\0 #\9))

(fn %nondecimal-digit? (x start base)
  (charrange? x start (code-char (+ (char-code start) (- base 10)))))

(fn nondecimal-digit? (x &key (base 10))
  (& (< 10 base)
     (| (%nondecimal-digit? x #\a base)
        (%nondecimal-digit? x #\A base))))

(fn digit-char? (c &key (base 10))
  (& (character? c)
     (| (decimal-digit? c)
        (nondecimal-digit? c :base base))))

(fn hex-digit-char? (x)
  (| (digit-char? x)
     (& (character>= x #\A) (character<= x #\F))
     (& (character>= x #\a) (character<= x #\f))))

(def-rest-predicate alphanumeric? c ()
  (| (alpha-char? c)
     (digit-char? c)))

(fn whitespace? (x)
  (& (character? x)
     (< (char-code x) 33)
     (>= (char-code x) 0)))

(fn control-char? (x)
  (character< x (code-char 32)))

(define-test "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(define-test "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)
