(defvar *standard-log* *standard-output*)

,(? *transpiler-log*
    '(defun log-message (txt)
       (%= nil (error_log txt))
       txt)
    '(defmacro log-message (txt)))
