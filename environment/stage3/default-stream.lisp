(fn default-stream (x ststr)
  (case x
    nil  (make-string-stream)
    t    stdstr
    x))

(defmacro with-default-stream (nstr str stdstr &body body)
  `(with (,g     ,str
          ,nstr  (default-stream ,g stdstr))
     (? ,g
        (progn
          ,@body)
        (get-stream-string ,nstr))))
