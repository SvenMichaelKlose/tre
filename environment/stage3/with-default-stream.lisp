;;;;; tré - Copyright (c) 2005-2006,2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-default-stream (nstr str &body body)
  (with-gensym (g body-result)
    `(with (,g ,str
	        ,nstr (?
        	        (eq ,g t)	 *standard-output*
        		    (eq ,g nil)  (make-string-stream)
				    ,g)
            ,body-result (progn ,@body))
       (? ,g
	      ,body-result
          (get-stream-string ,nstr)))))
