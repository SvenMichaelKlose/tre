(defun make-c-newlines (x)
  (list-string (mapcan [? (== 10 (char-code _))
                          `(#\\ #\n)
                          `(,_)]
                       (string-list x))))

(defun literal-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char chars-to-escape))
				 (string quote-char)))
