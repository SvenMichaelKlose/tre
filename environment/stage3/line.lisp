(fn terpri (&optional (str *standard-output*))
  (with-default-stream s str *standard-output*
    (stream-princ (code-char 10) s)
    (force-output s)
    nil))

(fn fresh-line (&optional (str *standard-output*))
  (with-default-stream s str *standard-output*
    (unless (fresh-line? s)
      (terpri s)
      t)))
