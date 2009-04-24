;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>

(defmacro with-default-stream (nstr str &rest body)
"Set 'str' to *standard-output* if 'str' is T or create string-stream
if 'str' is NIL, evaluate 'body' and return the stream-string if 'str'
is NIL."
  (with-gensym (g body-result)
    `(with (,g ,str
			,nstr nil)
	   (setq ,nstr (if
        		     (eq ,g t)		*standard-output*
        		     (eq ,g nil)	(make-string-stream)
				     ,g))
       (let ,body-result (progn
						   ,@body)
         (if ,g
		   ,body-result
           (get-stream-string ,nstr))))))
