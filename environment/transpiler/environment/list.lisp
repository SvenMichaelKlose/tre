(defun list (&rest x) x)

(defun list-length (x)
  (let len 0
    (while (cons? x)
           len
      (= x .x)
      (++! len))))

(defun last (x)
  (& x
     (? .x
        (last .x)
        x)))

(defun copy-list (x)
  (? (atom x)
     x
     (. x. (copy-list .x))))

(functional nthcdr)

(defun nthcdr (idx x)
  (& x
     (? (zero? idx)
        x
        (nthcdr (-- idx) .x))))

(functional nth)

(defun nth (i x)
  (car (nthcdr i x)))

(defun filter (func lst)
  (let result (. nil nil)
    (@ (i lst .result)
      (rplaca result
              (cdr (rplacd (| result.
                              result)
                           (list (funcall func i))))))))

(defun mapcar (func &rest lists)
  (let args (%map-args lists)
    (& args
       (. (apply func args)
          (apply #'mapcar func lists)))))
