;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>

(defmacro with-default-stream (str &rest body)
  "Set 'str' to *standard-output* if 'str' is T or create string-stream
   if 'str' is NIL, evaluate 'body' and return the stream-string if 'str'
   is NIL."
  (let ((g (gensym)))
    `(let ((,g str))
      (cond
        ((eq ,str t) (setq ,str *standard-output*))
        ((eq ,str nil) (setq ,str (make-string-output-stream))))
      ,@body
      (unless ,g
        (get-output-stream-string ,str)))))
