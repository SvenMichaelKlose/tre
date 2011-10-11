;;;;; tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

; XXX enable &REST/&KEY combination
(defun merge-unique (test &rest x)
  (with (result (make-queue)
         rec #'((x)
                 (when x
                   (dolist (i x)
                     (unless (member i. (queue-list result) :test test)
                       (enqueue result i.)))
                   (rec (remove-if #'not (mapcar #'cdr x))))))
    (rec x)
    (queue-list result)))
