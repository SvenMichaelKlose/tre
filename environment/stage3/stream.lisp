(var *default-stream-tabsize* 8)

(defstruct stream-location
  (track?   t)
  (id       nil)
  (line     1)
  (column   1)
  (tabsize  *default-stream-tabsize*))

(defstruct stream
  (handle           nil)

  fun-in
  fun-out
  fun-eof

  (last-char        nil)
  (peeked-char      nil)

  (input-location   (make-stream-location))
  (output-location  (make-stream-location :track? nil))

  (user-detail      nil))

(fn next-tabulator-column (column size)
  (integer (++ (* size (++ (/ (-- column) size))))))

(def-stream-location %track-location (stream-location x)
  (when track?
    (? (string? x)
       (adosequence x
         (%track-location stream-location !))
       (when x
         (? (== 10 (char-code x))
            {(= (stream-location-column stream-location) 1)
             (++! (stream-location-line stream-location))}
            (?
              (== 9 (char-code x)) (= (stream-location-column stream-location) (next-tabulator-column column tabsize))
              (< 31 (char-code x)) (++! (stream-location-column stream-location)))))))
  x)

(fn stream-princ (x str)
  (?
    (cons? x)            (@ (i x x)
                           (stream-princ i str))
    (| (string? x)
       (character? x))   (unless (& (string? x)
                                    (zero? (length x)))
                           (= (stream-last-char str) (? (string? x)
                                                        (elt x (-- (length x)))
                                                        x))
                           (%track-location (stream-output-location str) x)
                           (funcall (stream-fun-out str) x str))
    (funcall (stream-fun-out str) x str)))

(fn stream-track-input-location? (x)
  (stream-location-track? (stream-input-location x)))

(fn (= stream-track-input-location?) (v x)
  (= (stream-location-track? (stream-input-location x)) v))
