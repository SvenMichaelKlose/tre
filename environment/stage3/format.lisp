;;;;; tré – Copyright (c) 2006–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defstruct format-info
  stream
  text
  args
  (processed-args 0))

(defun %format-directive-eol (inf txt args)
  (terpri (format-info-stream inf))
  (%format inf txt args))

(defun %format-directive-placeholder (inf txt args)
  (? args
     (? (cons? args.)
		(late-print args. (format-info-stream inf))
        (princ args. (format-info-stream inf)))
     (error "Argument ~A specified in format \"~A\" is missing." (format-info-processed-args inf) (format-info-text inf)))
  (%format inf txt .args))

(defun %format-directive-force-output (inf txt args)
  (force-output (format-info-stream inf))
  (%format inf txt args))

(defun %format-directive-tilde (inf txt args)
  (princ #\~ (format-info-stream inf))
  (%format inf txt args))

(defun %format-directive (inf txt args)
  (++! (format-info-processed-args inf))
  (case (char-upcase txt.) :test #'character==
    #\% (%format-directive-eol inf .txt args)
    #\A (%format-directive-placeholder inf .txt args)
    #\F (%format-directive-force-output inf .txt args)
    (%format-directive-tilde inf txt args)))

(defun %format (inf txt args)
  (when txt
    (? (character== txt. #\~)
       (%format-directive inf .txt args)
       (progn
         (princ txt. (format-info-stream inf))
         (%format inf .txt args)))))

(defun format (str txt &rest args)
  (with-default-stream nstr str
    (with-temporary *print-automatic-newline?* nil
      (%format (make-format-info :stream nstr :text txt :args args) (string-list txt) args))))
