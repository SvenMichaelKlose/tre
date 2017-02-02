(defstruct format-info
  stream
  text
  args
  (processed-args 0))

(fn %format-directive-eol (inf txt args)
  (terpri (format-info-stream inf))
  (%format inf txt args))

(fn %format-directive-placeholder (inf txt args)
  (? args
     (? (cons? args.)
		(late-print args. (format-info-stream inf))
        (princ args. (format-info-stream inf)))
     (error "Argument ~A specified in format \"~A\" is missing." (format-info-processed-args inf) (format-info-text inf)))
  (%format inf txt .args))

(fn %format-directive-force-output (inf txt args)
  (force-output (format-info-stream inf))
  (%format inf txt args))

(fn %format-directive-fresh-line (inf txt args)
  (fresh-line (format-info-stream inf))
  (%format inf txt args))

(fn %format-directive-tilde (inf txt args)
  (princ #\~ (format-info-stream inf))
  (%format inf txt args))

(fn %format-directive (inf txt args)
  (++! (format-info-processed-args inf))
  (case (char-upcase txt.)
    #\%  (%format-directive-eol inf .txt args)
    #\A  (%format-directive-placeholder inf .txt args)
    #\F  (%format-directive-force-output inf .txt args)
    #\L  (%format-directive-fresh-line inf .txt args)
    #\~  {(princ txt. (format-info-stream inf))
          (%format inf .txt args)}
    (%format-directive-tilde inf txt args)))

(fn %format (inf txt args)
  (when txt
    (alet (format-info-stream inf)
      (?
        (eql txt. #\\)  {(princ txt. !)
                         (princ .txt. !)
                         (%format inf ..txt args)}
        (eql txt. #\~)  (%format-directive inf .txt args)
        {(princ txt. (format-info-stream inf))
         (%format inf .txt args)}))))

(fn format (str txt &rest args)
  (with-default-stream nstr str
    (%format (make-format-info :stream nstr :text txt :args args) (string-list txt) args)))

(fn neutralize-format-string (x)
  (list-string (mapcan [? (eql _ #\~)
                          (list _ _)
                          (list _)]
                       (string-list x))))
