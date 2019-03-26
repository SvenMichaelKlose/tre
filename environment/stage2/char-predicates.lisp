; tré – Copyright (c) 2005–2006,2008–2016 Sven Michael Klose <pixel@hugbox.org>

(functional lower-case? upper-case? alpha-char? digit-char? alphanumeric?)

(defmacro def-rest-predicate (name iter args test-expr)
  (with-gensym x
    `(defun ,name (&rest ,x ,@args)
       (@ (,iter ,x t)
         (| ,test-expr
            (return nil))))))

(defun charrange? (x start end)
  (range? (char-code x) (char-code start) (char-code end)))

(def-rest-predicate lower-case? c ()
  (charrange? c #\a #\z))

(def-rest-predicate upper-case? c ()
  (charrange? c #\A #\Z))

(def-rest-predicate alpha-char? c ()
  (| (lower-case? c)
     (upper-case? c)))

(defun decimal-digit? (x)
  (charrange? x #\0 #\9))

(defun %nondecimal-digit? (x start base)
  (charrange? x start (character+ start (code-char (- base 10)))))

(defun nondecimal-digit? (x &key (base 10))
  (& (< 10 base)
     (| (%nondecimal-digit? x #\a base)
        (%nondecimal-digit? x #\A base))))

(defun digit-char? (c &key (base 10))
  (& (character? c)
     (| (decimal-digit? c)
        (nondecimal-digit? c :base base))))

(defun character>= (a b)
  (>= (char-code a) (char-code b)))

(defun character<= (a b)
  (<= (char-code a) (char-code b)))

(defun hex-digit-char? (x)
  (| (digit-char? x)
     (& (character>= x #\A) (character<= x #\F))
     (& (character>= x #\a) (character<= x #\f))))

(def-rest-predicate alphanumeric? c ()
  (| (alpha-char? c)
     (digit-char? c)))

(defun whitespace? (x)
  (& (character? x)
     (< (char-code x) 33)
     (>= (char-code x) 0)))

(defun control-char? (x)
  (< x (code-char 32)))

(define-test "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(define-test "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)
