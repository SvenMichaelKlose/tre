;;;;; tré – Copyright (c) 2005–2006,2008-2012 Sven Michael Klose <pixel@copei.de>

(functional char-upcase char-downcase lower-case-p upper-case-p alpha-char-p digit-char-p alphanumericp
            char-code code-char)

(defun char-upcase (c)
  (? (lower-case-p c)
     (character+ c (character- #\A #\a))
     c))

(defun char-downcase (c)
  (? (upper-case-p c)
     (character+ c (character- #\a #\A))
     c))

(defmacro def-rest-predicate (name iter args test-expr)
  (with-gensym x
    `(defun ,name (&rest ,x ,@args)
       (dolist (,iter ,x t)
         (unless ,test-expr
           (return nil))))))

(def-rest-predicate lower-case-p c ()
  (range-p c #\a #\z))

(def-rest-predicate upper-case-p c ()
  (range-p c #\A #\Z))

(def-rest-predicate alpha-char-p c ()
  (or (lower-case-p c)
      (upper-case-p c)))

(defun decimal-digit? (x)
  (range-p x #\0 #\9))

(defun %nondecimal-digit? (x start base)
  (range-p x start (character+ start (character- base 10))))

(defun nondecimal-digit? (x &key (base 10))
  (and (< 10 base)
       (or (%nondecimal-digit? x #\a base)
           (%nondecimal-digit? x #\A base))))

(defun digit-char-p (c &key (base 10))
  (and (character? c)
       (or (decimal-digit? c)
           (nondecimal-digit? c :base base))))

(define-test "DIGIT-CHAR-P #\0"
  ((digit-char-p #\0))
  t)

(define-test "DIGIT-CHAR-P #\a"
  ((digit-char-p #\a))
  nil)

(def-rest-predicate alphanumericp c ()
  (or (alpha-char-p c)
      (digit-char-p c)))
