(defun digit (x)
  (code-char (? (< x 10)
                (+ (char-code #\0) x)
                (+ (char-code #\a) -10 x))))

(defun integer-string (x n r)
  (with (f #'((x)
                (. (digit (mod x r))
                   (unless (zero? (--! n))
                     (f (integer (/ x r)))))))
    (list-string (reverse (f x)))))

(defun print-hex (x n &optional (str *standard-output*))
  (princ (integer-string (integer x) n 16) (default-stream str)))

(defun print-hexbyte (x &optional (str *standard-output*))
  (print-hex x 2 str))

(defun print-hexword (x &optional (str *standard-output*))
  (print-hex x 4 str))

(defun print-hexdword (x &optional (str *standard-output*))
  (print-hex x 8 str))

(defun print-octal (x &optional (str *standard-output*))
  (princ (integer-string x 3 8) (default-stream str)))
