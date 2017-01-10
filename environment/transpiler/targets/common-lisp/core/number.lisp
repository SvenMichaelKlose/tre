(defbuiltin code-char (x)
  (? (cl:characterp x)
     x
     (cl:code-char x)))

(defun bits-integer (bits)
  (cl:reduce #'((a b)
                 (+ (* a 2) b))
             bits))

(defun number (x)
  (? (character? x)
     (char-code x)
     x))

(defun integer-bits (x)
  (alet (number x)
    (let l nil
      (dotimes (i 32)
        (cl:multiple-value-bind (i r) (cl:truncate ! 2)
          (= ! i)
          (cl:push r l)))
      (cl:coerce l 'cl:bit-vector))))

(defbuiltin bit-and (a b)
  (bits-integer (cl:bit-and (integer-bits a) (integer-bits b))))

(defbuiltin bit-or (a b)
  (bits-integer (cl:bit-ior (integer-bits a) (integer-bits b))))

(defbuiltin bit-xor (a b)
  (bits-integer (cl:bit-xor (integer-bits a) (integer-bits b))))

(defbuiltin >> (x bits)
  (dotimes (n bits x)
    (cl:multiple-value-bind (i r) (cl:truncate x 2)
      (= x i))))

(defbuiltin << (x bits)
  (dotimes (n bits x)
    (= x (* x 2))))
