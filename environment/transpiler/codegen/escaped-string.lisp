;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code-generation top-level

(defun transpiler-make-escaped-string (x quote-char)
  (string-concat (string quote-char)
				 (make-c-newlines (escape-string x quote-char))
				 (string quote-char)))
