;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; String stream

(defun make-string-output-stream ()
  "Makes stream which accumulates all strings written to it.
   See also GET-OUTPUT-STREAM-STRING."
  (make-stream
    :user-detail  (make-queue)
    :fun-out      #'(lambda (c str)
                      (enqueue (stream-user-detail str) c))))

(defun get-output-stream-string (str)
  "Returns string accumulated by string-output-stream. The stream is
   emptied. Seel also MAKE-STRING-OUTPUT-STREAM."
  (let* ((sl (queue-list (stream-user-detail str)))
        (l (length sl))
        (s (make-string l)))
    (do ((p sl (cdr p))
         (i 0 (1+ i)))
        ((endp p) s)
      (setf (elt s i) (car p)))))
