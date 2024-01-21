(fn integer-chars-0 (x)
  (!= (integer (mod x 10))
    (. (number-digit !)
       (& (<= 10 x)
          (integer-chars-0 (/ (- x !) 10))))))

(fn integer-chars (x)
  (reverse (integer-chars-0 (integer (abs x)))))

(fn decimals-chars (x)
  (!= (mod (* x 10) 10)
    (& (< 0 !)
       (. (number-digit (integer !))
          (decimals-chars !)))))

(fn princ-number (x str)
  (& (< x 0)
     (princ #\- str))
  (stream-princ (integer-chars x) str)
  (!= (mod x 1)
    (unless (== 0 !)
      (princ #\. str)
      (stream-princ (decimals-chars !) str))))
