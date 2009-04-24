;;;; TRE environment
;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream nstr str
    (with-queue q
       (do ((c (read-char nstr) (read-char nstr)))
           ((or (= c 10)
				(= c 13)
				(end-of-file nstr))
			(or (end-of-file nstr)
				(enqueue q c))
            (return-from read-line (list-string (queue-list q))))
         (enqueue q c)))))

(defun read-all-lines (&optional (str *standard-input*))
  (with-default-stream nstr str
    (unless (end-of-file nstr)
	  (cons (read-line nstr)
			(read-all-lines nstr)))))
