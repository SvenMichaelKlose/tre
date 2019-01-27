(fn read-binary (&optional (in *standard-input*))
  (let n 0
    (while (!? (peek-char in)
               (in? ! #\0 #\1))
           n
      (= n (bit-or (<< n 1) (- (read-byte in) (char-code #\0)))))))
