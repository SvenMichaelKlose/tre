;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun dct-1d (input len)
  (let ouput (make-array)
    (dotimes (i len output)
      (= (aref output i) 0)
      (dotimes (k len)
        (+! (aref output i) (* (aref input k) (/ (* i *pi* k) len)))))))

(defun dct-2d-coeffs (len)
  (let coeffs (make-array)
    (dotimes (i len coeffs)
      (let s (sqrt (/ (? (= 0 i) 1 2) len))
        (dotimes (j len)
          (= (aref coeffs i j) (* s (cos (* (/ *pi* len) i (+ j 0.5))))))))))

(defun dct-2d (coeffs input len &key (inverse? nil))
  (with (tmp (make-array)
         ouput (make-array))
    (dotimes (i len)
      (dotimes (j len)
        (let s 0
          (dotimes (k len)
            (+! s (* (? inverse?
                        (aref coeffs k j)
                        (aref coeffs j k))
                     (aref input i k)))
            (= (aref tmp i j) s)))))
    (dotimes (j len output)
      (dotimes (i len)
        (let s 0
          (dotimes (k len)
            (+! s (* (? inverse?
                        (aref coeffs k i)
                        (aref coeffs i k))
                     (aref tmp k j)))
            (= (aref output i j) s)))))))
