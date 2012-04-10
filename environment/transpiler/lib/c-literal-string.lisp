;;;;; TRE transpiler - Copyright (c) 2008-2009,2012 Sven Michael Klose <pixel@copei.de>

(defun c-literal-string (x quote-char &optional (chars-to-escape nil))
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char chars-to-escape))
				 (string quote-char)))
