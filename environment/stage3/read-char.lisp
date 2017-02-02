(fn read-peeked-char (str)
  (awhen (stream-peeked-char str)
    (= (stream-peeked-char str) nil)
    !))

(fn read-char-0 (str)
  (| (read-peeked-char str)
     (= (stream-last-char str) (funcall (stream-fun-in str) str))))

(fn read-char (&optional (str *standard-input*))
  (%track-location (stream-input-location str) (read-char-0 str)))

(fn peek-char (&optional (str *standard-input*))
  (| (stream-peeked-char str)
     (= (stream-peeked-char str) (read-char-0 str))))
