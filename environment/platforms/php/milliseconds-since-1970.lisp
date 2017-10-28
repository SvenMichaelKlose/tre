(fn milliseconds-since-1970 ()
  (!= (explode " " (microtime))
    (+ (integer (* 1000 (aref ! 1)))
       (integer (round (* 1000 (aref ! 0)))))))
