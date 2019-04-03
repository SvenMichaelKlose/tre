(functional string-concat string== upcase downcase list-string string-list queue-string)

(fn string<= (a b)
  (with (la  (length a)
         lb  (length b))
    (dotimes (i la (<= la lb))
      (& (character> (elt a i) (elt b i))
         (return nil)))))

(fn string-list (x)
  (let* ((l (length x))
         (s))
    (do ((i (-- l) (-- i)))
        ((< i 0))
      (= s (push (elt x i) s)))
    s))

(fn queue-string (x)
  (list-string (queue-list x)))

(fn string-array (x)
  (!= (make-array (length x))
    (dotimes (i (length x) !)
      (= (elt ! i) (elt x i)))))
