;;;;; tré – Copyright (C) 2005–2008,2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro with-string-stream (str &body body)
  `(let ,str (make-string-stream)
	 (progn
	   ,@body)
	 (get-stream-string ,str)))

(defmacro with-stream-string (str x &body body)
  `(let ,str (make-string-stream)
     (princ ,x ,str)
	 (progn
	   ,@body)))
