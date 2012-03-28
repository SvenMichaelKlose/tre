;;;;; tré - Copyright (c) 2006-2008,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun %format-directive-eol (str txt args)
  (terpri str)
  (%format str txt args))

(defun %format-directive-placeholder (str txt args)
  (? args
     (? (cons? args.)
		(late-print args. str)
        (princ args. str))
     (error "argument specified in format is missing"))
  (%format str txt .args))

(defun %format-directive-tilde (str txt args)
  (princ #\~ str)
  (%format str txt args))

(defun %format-directive (str txt args)
  (let el (char-upcase txt.)
    (?
      (character= el #\%) (%format-directive-eol str .txt args)
      (character= el #\A) (%format-directive-placeholder str .txt args)
      (%format-directive-tilde str txt args))))

(defun %format (str txt args)
  (when txt
    (? (character= txt. #\~)
       (%format-directive str .txt args)
       (progn
         (princ txt. str)
         (%format str .txt args)))))

(defun format (str txt &rest args)
  "Print formatted string."
  (with-default-stream nstr str
    (%format nstr (string-list txt) args)))
