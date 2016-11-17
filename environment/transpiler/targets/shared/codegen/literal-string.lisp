; tré – Copyright (c) 2008–2009,2012–2014,2016 Sven Michael Klose <pixel@copei.de>

; TODO: Make sure == works the same on all targets. PHP doesn't allow CHARs with it.
(defun make-c-newlines (x)
  (list-string (mapcan [? (== 10 (char-code _))
                          `(#\\ #\n)
                          `(,_)]
                       (string-list x))))

(defun literal-string (x &optional (quote-char #\") (chars-to-escape #\"))
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char chars-to-escape))
				 (string quote-char)))
