;;;;; tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>

(defun number-digit (x)
  (code-char (+ x #\0)))

(defun integer-chars-0 (x)
  (alet (integer (mod x 10))
    (cons (number-digit !)
          (& (<= 10 x)
             (integer-chars-0 (/ (- x !) 10))))))

(defun integer-chars (x)
  (reverse (integer-chars-0 (integer (abs x)))))

(defun fraction-chars-0 (x)
  (alet (mod (* x 10) 10)
    (& (< 0 !)
       (cons (number-digit !)
             (fraction-chars-0 !)))))

(defun fraction-chars (x)
  (fraction-chars-0 (mod (abs x) 1)))

(defun princ-number (x str)
  (& (< x 0)
     (princ #\- str))
  (stream-princ (integer-chars x) str)
  (alet (mod x 1)
    (unless (zero? !)
      (princ #\. str)
      (stream-princ (fraction-chars !) str))))

(defun princ (x &optional (str *standard-output*))
  (with-default-stream s str
    (?
      (string? x)    (stream-princ x s)
      (character? x) (stream-princ x s)
      (number? x)    (princ-number x s)
      (symbol? x)    (stream-princ (symbol-name x) s))
	x))
