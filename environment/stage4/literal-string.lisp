;;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun literal-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char chars-to-escape))
				 (string quote-char)))

(define-filter literal-strings #'literal-string)
