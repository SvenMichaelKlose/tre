;;;; TRE environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

(defun fresh-line? (&optional (str *standard-output*))
  "Test if stream is at the beginning of a line."
  (= (stream-last-char str) (code-char 10)))

(defun force-output (&optional (str *standard-output*))
  "Flush buffered output."
  (%force-output (stream-handle str)))

(defun read-char (&optional (str *standard-input*))
  "Read character from stream."
  (unless (end-of-file str)
    (if (eq (stream-peeked-char str) nil)
      (setf (stream-last-char str) (funcall (stream-fun-in str) str))
      (prog1
        (stream-peeked-char str)
        (setf (stream-peeked-char str) nil)))))

(defun peek-char (&optional (str *standard-input*))
  "Read character without stepping to next."
  (or (stream-peeked-char str)
      (setf (stream-peeked-char str) (read-char str))))

(defun end-of-file (&optional (str *standard-input*))
  "Test if stream is at file end."
  (when (stream-fun-eof str)
    (funcall (stream-fun-eof str) str)))
