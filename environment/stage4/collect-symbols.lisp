;;;;; TRE environment
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun collect-symbols (x)
  (with (ret (make-queue)
  		 rec #'((x)
				  (when x
    				(if (and (atom x)
							 (not (string= "" (symbol-name x))))
        			    (enqueue ret x)
        			    (when (consp x)
          			      (rec x.)
          			      (rec .x))))))
	(rec x)
	(queue-list ret)))
