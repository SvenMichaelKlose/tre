;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun digit-number (x)
  (- x #\0))

(defun peek-digit (str)
  (awhen (peek-char str)
    (& (digit-char-p !) !)))

(defun peek-dot (str)
  (awhen (peek-char str)
    (== #\. !)))

(defun read-mantissa-0 (str v s)
  (? (peek-digit str)
     (read-mantissa-0 str (+ v (* s (digit-number (read-char str)))) (/ s 10))
     v))

(defun read-mantissa (&optional (str *standard-input*))
  (& (!? (peek-char str)
         (digit-char-p !))
     (read-mantissa-0 str 0 0.1)))

(defun read-integer-0 (str v)
  (? (peek-digit str)
     (read-integer-0 str (+ (* v 10) (digit-number (read-char str))))
     v))

(defun read-integer (&optional (str *standard-input*))
  (& (peek-digit str)
     (integer (read-integer-0 str 0))))

(defun read-number (&optional (str *standard-input*))
  (+ (read-integer str)
     (| (& (peek-dot str)
           (read-char str)
           (read-mantissa str))
        0)))
