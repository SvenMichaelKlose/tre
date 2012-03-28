;;;;; tré - Copyright (c) 2005-2008,2010,2012 Sven Michael Klose <pixel@copei.de>

(defun fresh-line? (&optional (str *standard-output*))
  "Test if stream is at the beginning of a line."
  (= (stream-last-char str) (code-char 10)))

(defun read-char (&optional (str *standard-input*))
  "Read character from stream."
  (?
    (stream-peeked-char str)
      (prog1
        (stream-peeked-char str)
        (setf (stream-peeked-char str) nil))
    (not (end-of-file str))
      (setf (stream-last-char str) (funcall (stream-fun-in str) str))))

(defun peek-char (&optional (str *standard-input*))
  "Read character without stepping to next."
  (or (stream-peeked-char str)
      (setf (stream-peeked-char str) (read-char str))))

(defun end-of-file (&optional (str *standard-input*))
  "Test if stream is at file end."
  (when (stream-fun-eof str)
    (funcall (stream-fun-eof str) str)))
