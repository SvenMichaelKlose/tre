;;;;; nix list processor
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>
;
;;;; Pass 1:

(defun identity? (x)
  (and (consp x)
       (eq (car x) 'identity)))

(defun filter-identity (l)
  "Remove IDENTITY expressions."
  (mapcar #'((x)
              (if (and (consp x) (cdr x) (identity? (second x)))
				(list (car x) (second (second x)))
                  x))
		  l))

(defun clean-code (l)
  "Remove inital SETQ symbol from expressions."
  (mapcar #'((x)
              (if (consp x)
                  (case (car x)
                    ('%setq (cdr x))
                    (t x))
                  x))
          (remove-if #'identity? l)))

;;;; Toplevel

(defun tree-expand (fi l)
  (setf (funinfo-first-cblock fi) (filter-identity (clean-code l))))

(defun tree-expand-reset ()
  (setf *tags-cblocks* nil))
