(defvar *standard-log* *standard-output*)

,(? *transpiler-log*
    '(fn log-message (txt)
       (%= nil (error_log txt))
       txt)
    '(defmacro log-message (txt)
       txt))
