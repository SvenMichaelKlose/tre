; tré – Copyright (c) 2008–2013,2016 Sven Michael Klose <pixel@copei.de>

(defvar *standard-log* *standard-output*)

,(? *transpiler-log*
    '(defun log (txt)   ; TODO: Rename. Conflicts with math function.
       (%= nil (error_log txt))
       txt)
    '(defmacro log (txt)))
