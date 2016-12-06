; tré – Copyright (c) 2008–2013,2016 Sven Michael Klose <pixel@hugbox.org>

(functional digit-number)

(defun digit-number (x)
  (- (char-code x) (char-code #\0)))

(defun peek-digit (str)
  (awhen (peek-char str)
    (& (digit-char? !) !)))

(defun peek-dot (str)
  (awhen (peek-char str)
    (== #\. !)))

(defun read-decimal-places-0 (str v s)
  (? (peek-digit str)
     (read-decimal-places-0 str
                            (+ v (* s (digit-number (read-char str))))
                            (/ s 10))
     v))

(defun read-decimal-places (&optional (str *standard-input*))
  (& (!? (peek-char str)
         (digit-char? !))
     (read-decimal-places-0 str 0 0.1)))

(defun read-integer-0 (str v)
  (? (peek-digit str)
     (read-integer-0 str (+ (* v 10) (digit-number (read-char str))))
     v))

(defun read-integer (&optional (str *standard-input*))
  (& (peek-digit str)
     (integer (read-integer-0 str 0))))

(defun read-number (&optional (str *standard-input*))
  (* (? (== #\- (peek-char str))
        {(read-char str)
         -1}
        1)
     (+ (read-integer str)
        (| (& (peek-dot str)
              (read-char str)
              (read-decimal-places str))
           0))))
