;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    (%error ":direction not specified")))

(defun open (path &key direction)
  (awhen (%fopen path (%fopen-direction direction))
    (make-stream
        :handle !
		:fun-in #'((str) (%read-char (stream-handle str)))
		:fun-out #'((c str) (%princ c (stream-handle str)))
		:fun-eof #'((str) (%feof (stream-handle str))))))

(defun close (str)
  (%fclose (stream-handle str)))

(defmacro with-open-file (var file &rest body)
  (with-gensym g
    `(let ,var ,file
       (unless ,var
         (%error "couldn't open file"))
       (with (,g (progn ,@body))
		 (close ,var)
		 ,g))))
