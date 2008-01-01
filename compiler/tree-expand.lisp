;;;;; nix list processor
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun filter-identity (l)
  "Remove IDENTITY expressions."
  (mapcar #'((x)
              (if (and (consp x) (cdr x) (identity? (second x)))
				(list (car x) (second (second x)))
                  x))
		  l))

(defun remove-setq (l)
  "Remove inital SETQ symbol from expressions."
  (mapcar #'((x)
              (if (consp x)
                  (case (car x)
                    ('%setq (cdr x))
                    (t x))
                  x))
          (remove-if #'identity? l)))

(defun get-double-labels (x)
  (when x
	(if (and (atom (first x))
			 (consp (cdr x))
			 (atom (second x)))
	    (acons (first x) (second x) (get-double-labels (cdr x)))
		(get-double-labels (cdr x)))))

(defun clean-tags (x)
  (with (labs (get-double-labels x))
    x))

(defun tree-expand (fi l)
  (with (x (clean-tags (filter-identity (remove-setq l))))
    (setf (funinfo-first-cblock fi) x)))

(defun tree-expand-reset ()
  (setf *tags-cblocks* nil))
