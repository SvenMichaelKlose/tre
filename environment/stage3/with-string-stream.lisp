; tré – Copyright (C) 2005–2008,2012,2014,2016 Sven Michael Klose <pixel@copei.de>

(defmacro with-string-stream (str &body body)
  `(let ,str (make-string-stream)
	 {,@body}
	 (get-stream-string ,str)))

(defmacro with-stream-string (str x &body body)
  `(let ,str (make-string-stream)
     (princ ,x ,str)
	 {,@body}))
