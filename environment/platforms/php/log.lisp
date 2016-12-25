(defvar *standard-log* *standard-output*)

,(? *transpiler-log*
    '(defun log (txt)   ; TODO: Rename. Conflicts with math function.
       (%= nil (error_log txt))
       txt)
    '(defmacro log (txt)))
