;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008-2010 Sven Klose <pixel@copei.de>

(defun char-upcase (c)
  "Return upper case equivalent of lower case character."
  (code-char (if (lower-case-p c)
    			 (character+ c (character- #\A #\a))
    			 c)))

(defun char-downcase (c)
  "Return upper case equivalent of upper case character."
  (code-char (if (upper-case-p c)
    			 (character+ c (character- #\a #\A))
    			 c)))


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
	(and (characterp c)
   	     (or (digit-p)
      	     (and (< 10 base)
        	      (or (digit-alpha-p #\a)
				      (digit-alpha-p #\A)))))))

(def-rest-predicate alphanumericp c ()
  (or (alpha-char-p c)
      (digit-char-p c)))
