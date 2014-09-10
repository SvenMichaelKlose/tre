; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun read-binary (&optional (in *standard-input*))
  (let n 0
    (while (!? (peek-char in)
               (in=? ! #\0 #\1))
           n
      (= n (bit-or (<< n 1) (- (read-char in) #\0))))))
