;;;; tré – Copyright (c) 2005–2006,2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun %fopen-direction (direction)
  (case direction
    'input   "r"
    'output  "w"
    'append  "a"
    (%error ":direction not specified")))

(defun open (path &key direction)
  (!? (%fopen path (%fopen-direction direction))
      (make-stream
          :handle  !
          :in-id   path
          :fun-in  #'((str)
                        (%read-char (stream-handle str)))
          :fun-out #'((c str)
                        (%princ c (stream-handle str)))
          :fun-eof #'((str)
                        (%feof (stream-handle str))))
      (error "couldn't open file '~A'" ,path)))

(defun close (str)
  (%fclose (stream-handle str)))

(defmacro with-open-file (var file &rest body)
  (with-gensym g
    `(with (,var ,file
            ,g   (progn ,@body))
       (close ,var)
       ,g)))
