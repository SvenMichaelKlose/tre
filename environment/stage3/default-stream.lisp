(fn default-stream (x)
  (case x
    nil  (make-string-stream)
    t    *standard-output*
    x))

(defmacro with-default-stream (nstr str &body body)
  (with-gensym (g body-result)
    `(with (,g            ,str
            ,nstr         (default-stream ,g)
            ,body-result  {,@body})
       (? ,g
          ,body-result
          (get-stream-string ,nstr)))))
