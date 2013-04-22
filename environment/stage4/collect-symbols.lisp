;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun collect-symbols (x)
  (with (ret (make-queue)
  		 rec [& _
    			(? (& (symbol? _)
					  (not (string== "" (symbol-name _))))
        		   (enqueue ret _)
        		   (when (cons? _)
          		     (rec _.)
          		     (rec ._)))])
	(rec x)
	(queue-list ret)))
