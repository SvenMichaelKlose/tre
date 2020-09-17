(functional digit-number)

(fn digit-number (x)
  (- (char-code x) (char-code #\0)))

(fn peek-digit (str)
  (awhen (peek-char str)
    (& (digit-char? !) !)))

(fn peek-dot (str)
  (awhen (peek-char str)
    (eql #\. !)))

(fn read-decimal-places-0 (str v s)
  (? (peek-digit str)
     (read-decimal-places-0 str
                            (+ v (* s (digit-number (read-char str))))
                            (/ s 10))
     v))

(fn read-decimal-places (&optional (str *standard-input*))
  (& (!? (peek-char str)
         (digit-char? !))
     (read-decimal-places-0 str 0 0.1)))

(fn read-integer-0 (str v)
  (? (peek-digit str)
     (read-integer-0 str (+ (* v 10) (digit-number (read-char str))))
     v))

(fn read-integer (&optional (str *standard-input*))
  (& (peek-digit str)
     (integer (read-integer-0 str 0))))

(fn read-number (&optional (str *standard-input*))
  (* (? (eql #\- (peek-char str))
        (progn
          (read-char str)
          -1)
        1)
     (+ (read-integer str)
        (| (& (peek-dot str)
              (read-char str)
              (read-decimal-places str))
           0))))
