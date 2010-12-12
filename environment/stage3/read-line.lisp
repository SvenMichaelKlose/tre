;;;; TRE environment
;;;; Copyright (c) 2007,2010 Sven Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream nstr str
    (with-queue q
      (while (and (not (end-of-file nstr))
                  (not (let c (peek-char nstr)
                         (or (= c 10)
				             (= c 13)))))
              (progn
                (let lst (peek-char nstr)
                  (when (and (not (end-of-file nstr))
                             (or (= lst 10)
				                 (= lst 13)))
                    (enqueue q (read-char nstr))
                    (when (let c (peek-char nstr)
                            (and (not (end-of-file nstr))
                                 (or (= c 10)
				                     (= c 13))
                                 (not (= c lst))))
                      (enqueue q (read-char nstr)))))
                (return-from read-line (list-string (queue-list q))))
           (enqueue q (read-char nstr))))))

(defun read-all-lines (&optional (str *standard-input*))
  (with-default-stream nstr str
    (unless (end-of-file nstr)
	  (cons (read-line nstr)
			(read-all-lines nstr)))))
