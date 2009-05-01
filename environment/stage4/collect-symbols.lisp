;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun collect-symbols (x)
  (with (ret nil
  		 rec #'((x)
				  (when x
    				(if (and (atom x)
							 (not (string= "" (symbol-name x))))
        			  (push! x ret)
        			(when (consp x)
          			  (rec x.)
          			  (rec .x))))))
	(rec x)
	ret))
