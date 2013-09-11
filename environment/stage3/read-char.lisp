;;;;; tré – Copyright (c) 2005–2008,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun read-char-0 (str)
  (!?
    (stream-peeked-char str)
      (prog1
        !
        (= (stream-peeked-char str) nil))
    (not (end-of-file? str))
      (= (stream-last-char str) (funcall (stream-fun-in str) str))))

(defun read-char (&optional (str *standard-input*))
  (%track-location (stream-input-location str) (read-char-0 str)))

(defun peek-char (&optional (str *standard-input*))
  (| (stream-peeked-char str)
     (= (stream-peeked-char str) (read-char-0 str))))
