(fn integer-string (x n r)
  (with (f #'((x)
                (. (digit (mod x r))
                   (unless (== 0 (--! n))
                     (f (integer (/ x r)))))))
    (list-string (reverse (f x)))))

(fn print-hex (x n &optional (str *standard-output*))
  (princ (integer-string (integer x) n 16) (default-stream str)))

(fn print-hexbyte (x &optional (str *standard-output*))
  (print-hex x 2 str))

(fn print-hexword (x &optional (str *standard-output*))
  (print-hex x 4 str))

(fn print-hexdword (x &optional (str *standard-output*))
  (print-hex x 8 str))

(fn print-octal (x &optional (str *standard-output*))
  (princ (integer-string x 3 8) (default-stream str)))
