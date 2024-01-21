(fn make-string-stream ()
  (make-stream
      :user-detail
        (make-queue)
      :fun-in
        [queue-pop (stream-user-detail _)]
      :fun-out
        #'((x str)
            (? (string? x)
               (dosequence (i x)
                 (enqueue (stream-user-detail str) i))
               (enqueue (stream-user-detail str) x)))
      :fun-eof
        [not (queue-list (stream-user-detail _))]))

(fn get-stream-string (str)
  (prog1
    (queue-string (stream-user-detail str))
    (= (stream-user-detail str) (make-queue))))
