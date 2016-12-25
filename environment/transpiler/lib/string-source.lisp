(defun string-source (x)
  (with-stream-string s x
    (with-queue q
      (while (peek-char s)
             nil
        (enqueue q (read s)))
      (queue-list q))))
