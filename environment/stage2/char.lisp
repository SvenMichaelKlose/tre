;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2011 Sven Klose <pixel@copei.de>

(defun char-upcase (c)
  (if (lower-case-p c)
  	  (character+ c (character- #\A #\a))
      c))

(defun char-downcase (c)
  (if (upper-case-p c)
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

(defun digit-char-p (c &key (base 10))
  (labels ((digit-p ()
             (range-p c #\0 #\9))
           (digit-alpha-p (start)
             (range-p c start (character+ start (character- base 10)))))
	(and (character? c)
   	     (or (digit-p)
      	     (and (< 10 base)
        	      (or (digit-alpha-p #\a)
				      (digit-alpha-p #\A)))))))

(def-rest-predicate alphanumericp c ()
  (or (alpha-char-p c)
      (digit-char-p c)))
