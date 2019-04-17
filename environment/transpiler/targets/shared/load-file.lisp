(fn load-file-stream (s)
  (with-queue q
    (while (seek-char s)
           (queue-list q)
      (enqueue q (read s)))))

(fn load-file (name)
  (with-open-file s (open name :direction 'input)
    (load-file-stream s)))

(fn load-string (x)
  (with-stream-string s x
    (load-file-stream s)))
