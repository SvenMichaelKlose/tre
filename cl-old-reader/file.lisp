;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %princ (x stream) (princ x stream))
(defun %force-output (stream) (force-output stream))

(defun %fopen (pathname mode)
  (open pathname :direction (? (find #\w mode :test #'equal)
                               :output
                               :input)
                 :if-exists :supersede))

(defun %fclose (stream) (close stream))

(defun %read-char (str)
  (alet (cl-read-char str nil 'eof)
    (unless (eq ! 'eof) !)))

(defun unix-sh-mkdir (pathname &key (parents nil))
  (ensure-directories-exist pathname))
