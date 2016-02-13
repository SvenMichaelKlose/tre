; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@copei.de>

(defbuiltin number? (x)
  (| (cl:numberp x)
     (cl:characterp x)))

(defbuiltin integer (x)
  (cl:floor x))

(defun chars-to-numbers (x)
  (cl:mapcar (lambda (x)
               (? (cl:characterp x)
                  (cl:char-code x)
                  x))
             x))

(defbuiltin code-char (x)
  (? (cl:characterp x)
     x
     (cl:code-char (cl:floor x))))

(defbuiltin == (&rest x) (apply #'cl:= (chars-to-numbers x)))
(defbuiltin number== (&rest x) (apply #'cl:= (chars-to-numbers x)))
(defbuiltin integer== (&rest x) (apply #'cl:= (chars-to-numbers x)))
(defbuiltin character== (&rest x) (apply #'cl:= (chars-to-numbers x)))
(defbuiltin %+ (&rest x) (apply #'cl:+ (chars-to-numbers x)))
(defbuiltin %- (&rest x) (apply #'cl:- (chars-to-numbers x)))
(defbuiltin %* (&rest x) (apply #'cl:* (chars-to-numbers x)))
(defbuiltin %/ (&rest x) (apply #'cl:/ (chars-to-numbers x)))
(defbuiltin %< (&rest x) (apply #'cl:< (chars-to-numbers x)))
(defbuiltin %> (&rest x) (apply #'cl:> (chars-to-numbers x)))
(defbuiltin number+ (&rest x) (apply #'%+ x))
(defbuiltin integer+ (&rest x) (apply #'%+ x))
(defbuiltin character+ (&rest x) (code-char (apply #'%+ x)))
(defbuiltin number- (&rest x) (apply #'%- x))
(defbuiltin integer- (&rest x) (apply #'%- x))
(defbuiltin character- (&rest x) (code-char (apply #'%- x)))
(defbuiltin * (&rest x) (apply #'%* x))
(defbuiltin / (&rest x) (apply #'%/ x))
(defbuiltin < (&rest x) (apply #'%< x))
(defbuiltin > (&rest x) (apply #'%> x))

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
  (alet (number x)
    (dotimes (n bits !)
      (cl:multiple-value-bind (i r) (cl:truncate ! 2)
        (= ! i)))))

(defbuiltin << (x bits)
  (alet (number x)
    (dotimes (n bits !)
      (= ! (* ! 2)))))
