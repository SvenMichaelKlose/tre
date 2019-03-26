; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@hugbox.org>

(defun number-digit (x)
  (code-char (+ x #\0)))

(defun integer-chars-0 (x)
  (alet (integer (mod x 10))
    (. (number-digit !)
       (& (<= 10 x)
          (integer-chars-0 (/ (- x !) 10))))))

(defun integer-chars (x)
  (reverse (integer-chars-0 (integer (abs x)))))

(defun decimals-chars (x)
  (alet (mod (* x 10) 10)
    (& (< 0 !)
       (. (number-digit !)
          (decimals-chars !)))))

(defun princ-number (x str)
  (& (< x 0)
     (princ #\- str))
  (stream-princ (integer-chars x) str)
  (alet (mod x 1)
    (unless (zero? !)
      (princ #\. str)
      (stream-princ (decimals-chars !) str))))
