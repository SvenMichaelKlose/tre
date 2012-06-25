;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun collect-symbols (x)
  (with (ret (make-queue)
  		 rec #'((x)
				  (when x
    				(? (and (atom x)
							(not (string== "" (symbol-name x))))
        			   (enqueue ret x)
        			   (when (cons? x)
          			     (rec x.)
          			     (rec .x))))))
	(rec x)
	(queue-list ret)))
