;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun %princ (x stream) (cl:princ x stream))
(defun %force-output (stream) (cl:force-output stream))

(defun %fopen (pathname mode)
  (cl:open pathname :direction (? (cl:find #\w mode :test #'cl:equal)
                               :output
                               :input)
                 :if-exists :supersede))

(defun %fclose (stream) (cl:close stream))

(defun read-char (str)
  (alet (cl:read-char str nil 'eof)
    (unless (eq ! 'eof) !)))

(defun unix-sh-mkdir (pathname &key (parents nil))
  (cl:ensure-directories-exist pathname))
