;;;; nix operating system project
;;;; list processor
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; File streams

(defun %fopen-direction (direction)
  (case direction
    ('input   "r")
    ('output  "w")
    (t	      (error ":direction not specified"))))

(defun open (path &key direction)
  "Open a file and return a stream object."
  (awhen (%fopen path (%fopen-direction direction))
    (make-stream :handle !
		 :fun-in #'(lambda (str) (%read-char (stream-handle str)))
		 :fun-out #'(lambda (c str) (%princ c (stream-handle str)))
		 :fun-eof #'(lambda (str) (%feof (stream-handle str))))))

(defmacro with-open-file (var file &rest body)
  `(let ((,var ,file))
     (unless ,var
       (error "couldn't open file"))
     ,@body)) ; XXX need to close file
