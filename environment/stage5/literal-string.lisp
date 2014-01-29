;;;;; tré – Copyright (c) 2008–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun make-c-newlines (x)
  (list-string (mapcan [? (== 10 _)
                          `(#\\ #\n)
                          `(,_)]
                       (string-list x))))

(defun literal-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char chars-to-escape))
				 (string quote-char)))
