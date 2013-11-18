;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate error_log)

,(? *transpiler-log*
    '(defun log (txt)
       (%= nil (error_log txt))
       txt)
    '(defmacro log (txt)))
