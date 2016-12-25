(defun read-peeked-char (str)
  (awhen (stream-peeked-char str)
    (= (stream-peeked-char str) nil)
    !))

(defun read-char-0 (str)
  (| (read-peeked-char str)
     (= (stream-last-char str) (funcall (stream-fun-in str) str))))

(defun read-char (&optional (str *standard-input*))
  (%track-location (stream-input-location str) (read-char-0 str)))

(defun peek-char (&optional (str *standard-input*))
  (| (stream-peeked-char str)
     (= (stream-peeked-char str) (read-char-0 str))))
