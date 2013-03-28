;;;;; tré – Copyright (c) 2007,2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream nstr str
    (with-queue q
      (while (& (not (end-of-file nstr))
                (not (let c (peek-char nstr)
                       (| (== c 10)
		                  (== c 13)))))
             (progn
               (let lst (peek-char nstr)
                 (when (& (not (end-of-file nstr))
                          (| (== lst 10)
			                 (== lst 13)))
                  (enqueue q (read-char nstr))
                  (when (let c (peek-char nstr)
                          (& (not (end-of-file nstr))
                             (| (== c 10)
		                        (== c 13))
                             (not (== c lst))))
                    (enqueue q (read-char nstr)))))
                (return-from read-line (list-string (queue-list q))))
           (enqueue q (read-char nstr))))))

(defun read-all-lines (&optional (str *standard-input*))
  (with-default-stream nstr str
    (with-queue q
      (while (not (end-of-file nstr))
             (queue-list q)
	    (enqueue q (read-line nstr))))))
