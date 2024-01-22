(fn format (str text &rest args)
  (with-default-stream s str
    (with (processed-args 0
           err-missing
             #'(()
                 (error "Argument ~A specified in format \"~A\" is missing."
                        processed-args text))
           eol
            #'((txt args)
                (terpri s)
                (f txt args))

          d-placeholder
            #'((txt args)
                (? args
                   (? (cons? args.)
                      (late-print args. s)
                      (princ args. s))
                   (err-missing))
                (f txt .args))

          d-hexadecimal
            #'((txt args)
                (? args
                   (? (cons? args.)
                      (late-print args. s)
                      (? (< args. 256)
                          (print-hexbyte args. s)
                          (print-hexword args. s)))
                   (err-missing))
                (f txt .args))

          d-force-output
            #'((txt args)
                (force-output s)
                (f txt args))

          d-fresh-line
            #'((txt args)
                (fresh-line s)
                (f txt args))

          tilde
            #'((txt args)
                (princ #\~ s)
                (f txt args))

          directive
            #'((txt args)
                (++! processed-args)
                (case txt.
                  #\%  (eol .txt args)
                  #\A  (d-placeholder .txt args)
                  #\X  (d-hexadecimal .txt args)
                  #\F  (d-force-output .txt args)
                  #\L  (d-fresh-line .txt args)
                  #\~  (progn
                         (princ txt. s)
                         (f .txt args))
                  (tilde txt args)))

          f #'((txt args)
                (when txt
                  (?
                    (eql txt. #\\)
                      (progn
                        (princ txt. s)
                        (princ .txt. s)
                        (f ..txt args))
                    (eql txt. #\~)
                      (directive .txt args)
                    (progn
                      (princ txt. s)
                      (f .txt args))))))
    (f (string-list text) args))))

(fn neutralize-format-string (x)
  (list-string (mapcan [? (eql _ #\~)
                          (list _ _)
                          (list _)]
                       (string-list x))))
