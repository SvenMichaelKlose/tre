; TODO: BIT-STREAMs are not flushed automatically! Write extra 8 bits at the end!

(defstruct bit-stream-info
  in
  out
  (in-bit    0)
  (out-bit   128)
  (in-byte   0)
  (out-byte  0))

(defun make-bit-stream (&key (in nil) (out nil))
  (make-stream
      :user-detail (make-bit-stream-info :in in :out out)
      :fun-in #'((str)
                  (block nil
                    (let info (stream-user-detail str)
                      (when (zero? (bit-stream-info-in-bit info))
                        (= (bit-stream-info-in-bit info) 128)
                        (!? (read-byte (bit-stream-info-in info))
                            (= (bit-stream-info-in-byte info) !)
                            (return)))
                      (prog1 (code-char (? (zero? (bit-and (bit-stream-info-in-byte info)
                                                           (bit-stream-info-in-bit info)))
                                           0 1))
                        (= (bit-stream-info-in-bit info) (>> (bit-stream-info-in-bit info) 1))))))
      :fun-out #'((x str)
                   (let info (stream-user-detail str)
                     (unless (zero? (? (character? x)
                                       (char-code x)
                                       x))
                       (= (bit-stream-info-out-byte info) (bit-or (bit-stream-info-out-byte info)
                                                                  (bit-stream-info-out-bit info))))
                     (= (bit-stream-info-out-bit info) (>> (bit-stream-info-out-bit info) 1))
                     (when (zero? (bit-stream-info-out-bit info))
                       (write-byte (bit-stream-info-out-byte info) (bit-stream-info-out info))
                       (= (bit-stream-info-out-bit info) 128)
                       (= (bit-stream-info-out-byte info) 0))))
	  :fun-eof #'((str)
                   (stream-fun-eof (bit-stream-info-in (stream-user-detail str))))))
