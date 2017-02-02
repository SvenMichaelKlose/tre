(fn fetch-file (path)
  (with-input-file in path
    (= (stream-track-input-location? in) nil)
    (with-queue q
      (awhile (read-char in)
              (list-string (queue-list q))
        (enqueue q !)))))

(fn fetch-all-lines (path)
  (with-input-file in path
    (= (stream-track-input-location? in) nil)
    (read-all-lines in)))

(fn put-file (path data)
  (with-output-file out path
    (princ data out)))
