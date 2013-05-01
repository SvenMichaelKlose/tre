;;;;; tré – Copyright (c) 2005–2006,2008–2013 Sven Michael Klose <pixel@copei.de>

(functional char-upcase char-downcase lower-case? upper-case? alpha-char? digit-char? alphanumeric?
            char-code code-char)

(defun char-upcase (c)
  (? (lower-case? c)
     (character+ c (character- #\A #\a))
     c))

(defun char-downcase (c)
  (? (upper-case? c)
     (character+ c (character- #\a #\A))
     c))

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

(define-test "DIGIT-CHAR? #\0"
  ((digit-char? #\0))
  t)

(define-test "DIGIT-CHAR? #\a"
  ((digit-char? #\a))
  nil)

(def-rest-predicate alphanumeric? c ()
  (| (alpha-char? c)
     (digit-char? c)))
