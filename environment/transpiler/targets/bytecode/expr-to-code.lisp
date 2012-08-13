;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun get-tag-indexes (x)
  (with (indexes (make-queue)
         rec #'((x i)
                  (& x 
                     (?
                       (eq '%quote x.)
                         (rec ..x (+ 2 i))
                       (eq '%%tag x.)
                         (progn
                           (enqueue indexes (cons .x. i))
                           (rec ..x i))
                       (rec .x (1+ i))))))
    (rec x 0)
    (print (queue-list indexes))))

(defun translate-jumps (indexes x)
  (with (get-tag-index (fn & _ (| (assoc-value _ indexes :test #'==)
                                  (error "cannot get bytecode index ~A in ~A" _ indexes)))
         rec #'((x)
                  (& x 
                     (? (eq '%%tag x.)
                        (rec ..x)
                        (cons x. (case x. :test #'eq
                                   '%quote       (cons .x. (rec ..x))
                                   '%%vm-go-nil  (cons .x. (cons ..x. (cons (get-tag-index ...x.) (rec ....x))))
                                   '%%vm-go      (cons (get-tag-index .x.) (rec ..x))
                                   (rec .x)))))))
    (rec x)))

(defun make-bytecode-function (fi x)
  `(,(funinfo-name fi)
    ,(funinfo-argdef fi)
    ,(length (funinfo-env fi))
    ,@(translate-jumps (get-tag-indexes x) x)))

(defun get-next-function (x)
  (cdr (member '%%%bc-fun x :test #'eq)))

(defun expr-to-code (expr)
  (let-when x (get-next-function expr)
    (cons (make-bytecode-function (get-funinfo-by-sym x.) (copy-while (fn not (eq _ '%%bc-return)) .x))
          (expr-to-code (cdr (member '%%bc-return ..x :test #'eq))))))

(defun load-bytecode-function (x)
  (= (symbol-function x.) (list-array .x)))

(defun load-bytecode-functions (x)
  (map (fn (format t "Loading bytecode function ~A.~%" _.)
           (late-print (list-array ._)))
       x)
  (dolist (i x)
    (= (symbol-function i.) (list-array .i)))
  x)
