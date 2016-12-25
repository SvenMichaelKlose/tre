(defmacro with-string-stream (str &body body)
  `(let ,str (make-string-stream)
	 {,@body}
	 (get-stream-string ,str)))

(defmacro with-stream-string (str x &body body)
  `(let ,str (make-string-stream)
     (princ ,x ,str)
	 {,@body}))
