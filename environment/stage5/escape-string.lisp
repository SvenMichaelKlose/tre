(defun escape-charlist (x &optional (quote-char #\") (chars-to-escape #\"))
  (when x
    (= chars-to-escape (ensure-list chars-to-escape))
    (?
	  (eql #\\ x.)
        (. #\\ (? (& .x (digit-char? .x.))
                  (escape-charlist .x quote-char chars-to-escape)
                  (. #\\ (escape-charlist .x quote-char chars-to-escape))))
	  (eql quote-char x.)
        (. #\\ (. x. (escape-charlist .x quote-char chars-to-escape)))
      (member x. chars-to-escape :test #'character==)
        (. #\\ (. x. (escape-charlist .x quote-char chars-to-escape)))
      (. x. (escape-charlist .x quote-char chars-to-escape)))))

(defun escape-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (declare type string x)
  (list-string (escape-charlist (string-list x) quote-char chars-to-escape)))
