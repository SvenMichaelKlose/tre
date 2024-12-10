(fn default-stream (x)
  (case x
    nil  (make-string-stream)
    t    *standard-output*
    x))

(defmacro with-default-stream (nstr str &body body)
  `(with (,g     ,str
          ,nstr  (default-stream ,g))
     (? ,g
        (progn
          ,@body)
        (get-stream-string ,nstr))))
