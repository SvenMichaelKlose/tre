;;;;; tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>

(defun %princ-character (c str)
  (unless (& (string? c) (zero? (length c)))
    (? (cons? c)
       (dolist (i c c)
         (%princ-character i str))
       (progn
         (= (stream-last-char str) (? (string? c)
                                      (elt c (1- (length c)))
                                      c))
         (funcall (stream-fun-out str) c str)))))

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
       (cons (number-digit !) (fraction-chars-0 !)))))

(defun fraction-chars (x)
  (fraction-chars-0 (mod (abs x) 1)))

(defun %princ-number (c str)
  (when (< c 0)
    (princ #\- str))
  (%princ-character (integer-chars c) str)
  (alet (mod c 1)
    (unless (zero? !)
      (princ #\. str)
      (%princ-character (fraction-chars !) str))))

(defun %princ-string (obj str)
  (%princ-character obj str))

(defun princ (obj &optional (str *standard-output*))
  "Print object in human readable format."
  (with-default-stream s str
    (?
      (string? obj) (%princ-string obj s)
      (character? obj) (%princ-character obj s)
      (number? obj) (%princ-number obj s)
      (symbol? obj) (%princ-string (symbol-name obj) s))
	obj))

(defun terpri (&optional (str *standard-output*))
  "Open a new line."
  (with-default-stream s str
    (%princ-character (code-char 10) s)
    (force-output s)
    nil))

(defun fresh-line (&optional (str *standard-output*))
  "Open a new line if not already opened."
  (with-default-stream s str
    (unless (fresh-line? s)
      (terpri s)
      t)))
