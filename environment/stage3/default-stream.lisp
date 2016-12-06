; tré – Copyright (c) 2005–2006,2008–2009,2012–2013,2016 Sven Michael Klose <pixel@copei.de>

(defun default-stream (x)
  (case x :test #'eq
    nil  (make-string-stream)
    t	 *standard-output*
	x))

(defmacro with-default-stream (nstr str &body body)
  (with-gensym (g body-result)
    `(with (,g            ,str
	        ,nstr         (default-stream ,g)
            ,body-result  {,@body})
       (? ,g
	      ,body-result
          (get-stream-string ,nstr)))))
