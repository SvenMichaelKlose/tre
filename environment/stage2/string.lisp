(functional string-concat string== upcase downcase list-string string-list queue-string)

(defun string<= (a b)
  (with (la  (length a)
         lb  (length b))
    (dotimes (i la (<= la lb))
      (& (character> (elt a i) (elt b i))
         (return nil)))))

(defun string-list (x)
  (let* ((l (length x))
		 (s))
    (do ((i (-- l) (-- i)))
		((< i 0))
      (= s (push (elt x i) s)))
	s))

(defun queue-string (x)
  (list-string (queue-list x)))

(defun string-array (x)
  (alet (make-array (length x))
    (dotimes (i (length x) !)
      (= (elt ! i) (elt x i)))))
