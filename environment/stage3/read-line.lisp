;;;;; tré – Copyright (c) 2007,2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun cr-or-lf? (x)
  (in=? x 10 13))

(defun read-line (&optional (str *standard-input*))
  (with-default-stream nstr str
    (with-queue q
      (while (!? (peek-char nstr)
                 (not (cr-or-lf? !)))
             (!? (peek-char nstr)
                 (when (cr-or-lf? !)
                   (enqueue q (read-char nstr))
                   (let-when c (peek-char nstr)
                     (when (& (cr-or-lf? c)
                              (not (== c !)))
                       (enqueue q (read-char nstr))))))
        (enqueue q (read-char nstr)))
      (!? (queue-list q)
          (list-string !)))))

(defun read-all-lines (&optional (str *standard-input*))
  (with-default-stream nstr str
    (with-queue q
      (awhile (read-line nstr)
              (queue-list q)
	    (enqueue q !)))))
