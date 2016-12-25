(defun terpri (&optional (str *standard-output*))
  (with-default-stream s str
    (stream-princ (code-char 10) s)
    (force-output s)
    nil))

(defun fresh-line (&optional (str *standard-output*))
  (with-default-stream s str
    (unless (fresh-line? s)
      (terpri s)
      t)))
