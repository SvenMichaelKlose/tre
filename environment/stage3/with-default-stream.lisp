;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro with-default-stream (nstr str &rest body)
"Set 'str' to *standard-output* if 'str' is T or create string-stream
if 'str' is NIL, evaluate 'body' and return the stream-string if 'str'
is NIL."
  (with-gensym (g ng)
    `(with (,g ,str
			,nstr nil)
	   (setq ,nstr (if
        		     (eq ,g t)		*standard-output*
        		     (eq ,g nil)	(make-string-stream)
				     ,g))
       ,@body
       (unless ,g
         (get-stream-string ,nstr)))))
