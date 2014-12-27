; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defbuiltin %princ (x stream) (cl:princ x stream))
(defbuiltin %force-output (stream) (cl:force-output stream))

(defbuiltin %fopen (pathname mode)
  (cl:open pathname :direction (? (cl:find #\w mode :test #'cl:equal)
                               :output
                               :input)
                 :if-exists :supersede))

(defbuiltin %fclose (stream) (cl:close stream))

(defbuiltin %read-char (str)
  (alet (cl:read-char str nil 'eof)
    (unless (eq ! 'eof) !)))

(defbuiltin unix-sh-mkdir (pathname &key (parents nil))
  (cl:ensure-directories-exist pathname))
