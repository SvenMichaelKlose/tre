;;;;; tré – Copyright (C) 2005–2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-string-stream (x &rest body)
  `(let ,x (make-string-stream)
	 (progn
	   ,@body)
	 (get-stream-string ,x)))

(defmacro with-stream-string (x str &rest body)
  `(let ,x (make-string-stream)
     (princ ,str ,x)
	 (progn
	   ,@body)))
