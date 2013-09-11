;;;;; tré – Copyright (c) 2005–2006,2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro with-default-stream (nstr str &body body)
  (with-gensym (g body-result)
    `(with (,g    ,str
	        ,nstr (case ,g :test #'eq
        		    nil  (make-string-stream)
        	        t	 *standard-output*
				    ,g)
            ,body-result (progn ,@body))
       (? ,g
	      ,body-result
          (get-stream-string ,nstr)))))
