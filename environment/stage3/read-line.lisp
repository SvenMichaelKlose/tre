(fn cr-or-lf? (x)
  (in? (char-code x) 10 13))

(fn read-line (&optional (str *standard-input*))
  (with-default-stream nstr str
    (with-queue q
      (while (!? (peek-char nstr)
                 (not (cr-or-lf? !)))
             (!? (peek-char nstr)
                 (when (cr-or-lf? !)
                   (enqueue q (read-char nstr))
                   (let-when c (peek-char nstr)
                     (when (& (cr-or-lf? c)
                              (not (character== c !)))
                       (enqueue q (read-char nstr))))))
        (enqueue q (read-char nstr)))
      (!? (queue-list q)
          (list-string !)))))

(fn read-all-lines (&optional (str *standard-input*))
  (with-default-stream nstr str
    (with-queue q
      (awhile (read-line nstr)
              (queue-list q)
        (enqueue q !)))))
