;;;;; tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>

(functional lower-case? upper-case? alpha-char? digit-char? alphanumeric?)

(defmacro def-rest-predicate (name iter args test-expr)
  (with-gensym x
    `(defun ,name (&rest ,x ,@args)
       (dolist (,iter ,x t)
         (| ,test-expr
            (return nil))))))

(def-rest-predicate lower-case? c ()
  (range? c #\a #\z))

(def-rest-predicate upper-case? c ()
  (range? c #\A #\Z))

(def-rest-predicate alpha-char? c ()
  (| (lower-case? c)
     (upper-case? c)))

(defun decimal-digit? (x)
  (range? x #\0 #\9))

(defun %nondecimal-digit? (x start base)
  (range? x start (character+ start (character- base 10))))

(defun nondecimal-digit? (x &key (base 10))
  (& (< 10 base)
     (| (%nondecimal-digit? x #\a base)
        (%nondecimal-digit? x #\A base))))

(defun digit-char? (c &key (base 10))
  (& (character? c)
     (| (decimal-digit? c)
        (nondecimal-digit? c :base base))))

(defun hex-digit-char? (x)
  (| (digit-char? x)
     (& (>= x #\A) (<= x #\F))
     (& (>= x #\a) (<= x #\f))))

(def-rest-predicate alphanumeric? c ()
  (| (alpha-char? c)
     (digit-char? c)))

(defun whitespace? (x)
  (& (< x 33)
     (>= x 0)))

(defun control-char? (x)
  (< x 32))

(define-test "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(define-test "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)
