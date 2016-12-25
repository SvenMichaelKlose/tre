(defun random-hexadecimal-digit ()
  (digit (integer (* (random) 16))))

(defun random-hexadecimal-digits (num)
  (with-queue q
    (dotimes (i num (queue-list q))
      (enqueue q (random-hexadecimal-digit)))))

(defun uuid (&key (version 4))
  (| (== 4 version)
     (error "Only RFC4122 UUID version 4 is supported."))
  (list-string
    (+ (random-hexadecimal-digits 8)
       (list #\-)
       (random-hexadecimal-digits 4)
       (list #\-)
       (list #\4)
       (random-hexadecimal-digits 3)
       (list #\- (elt '(#\8 #\9 #\a #\b) (integer (* 4 (random)))))
       (random-hexadecimal-digits 3)
       (list #\-)
       (random-hexadecimal-digits 12))))
