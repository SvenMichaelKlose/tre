(defbuiltin code-char (x)
  (? (CL:CHARACTERP x)
     x
     (CL:CODE-CHAR x)))

(fn bits-integer (bits)
  (CL:REDUCE #'((a b)
                 (+ (* a 2) b))
             bits))

(fn number (x)
  (? (character? x)
     (char-code x)
     x))

(fn integer-bits (x)
  (!= (number x)
    (let l nil
      (dotimes (i 32)
        (CL:MULTIPLE-VALUE-BIND (i r) (CL:TRUNCATE ! 2)
          (= ! i)
          (CL:PUSH r l)))
      (CL:COERCE l 'CL:BIT-VECTOR))))

(defbuiltin bit-and (a b)
  (bits-integer (CL:BIT-AND (integer-bits a) (integer-bits b))))

(defbuiltin bit-or (a b)
  (bits-integer (CL:BIT-IOR (integer-bits a) (integer-bits b))))

(defbuiltin bit-xor (a b)
  (bits-integer (CL:BIT-XOR (integer-bits a) (integer-bits b))))

(defbuiltin >> (x bits)
  (dotimes (n bits x)
    (CL:MULTIPLE-VALUE-BIND (i r) (CL:TRUNCATE x 2)
      (= x i))))

(defbuiltin << (x bits)
  (dotimes (n bits x)
    (= x (* x 2))))
