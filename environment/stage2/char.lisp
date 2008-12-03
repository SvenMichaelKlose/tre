;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; Character functions

(defun lower-case-p (c)
  "Return T if character is lower case."
  (range-p c #\a #\z))

(defun upper-case-p (c)
  "Return T if character is upper case."
  (range-p c #\A #\Z))

(defun alpha-char-p (c)
  "Return T if argument is an alphabetic character."
  (or (lower-case-p c)
      (upper-case-p c)))

(defun char-upcase (c)
  "Return upper case equivalent of lower case character."
  (if (lower-case-p c)
    (+ c (- #\A #\a))
    c))

(defun char-downcase (c)
  "Return upper case equivalent of upper case character."
  (if (upper-case-p c)
    (+ c (- #\a #\A))
    c))

(defun digit-char-p (c &optional base)
  "Return T if character is a digit."
  (labels ((digit-p ()
             (range-p c #\0 #\9))
           (digit-alpha-p (start)
             (range-p c start (+ start (- base 10)))))
   	(or (digit-p)
      	(and base
        	 (or (digit-alpha-p #\a)
				 (digit-alpha-p #\A))))))

(defun alphanumericp (c)
  "Return T if character is alphabetical."
  (or (alpha-char-p c)
      (digit-char-p c)))
