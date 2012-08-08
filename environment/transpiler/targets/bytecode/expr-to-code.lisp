;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun get-tag-indexes (x)
  (with (indexes (make-queue)
         rec #'((x i)
                  (& x (? (eq '%%tag x.)
                          (progn
                            (enqueue indexes (cons .x. i))
                            (rec ..x i))
                          (rec .x (1+ i))))))
    (rec x 0)
    (print (queue-list indexes))))

(defun translate-jumps (indexes x)
  (with (get-tag-index (fn | (assoc-value _ indexes :test #'==)
                             (error "cannot get bytecode index ~A in ~A" _ indexes))
         rec #'((x)
                (print (subseq x 0 4))
                  (& x 
                     (let e x.
                       (?
                         (eq '%%tag e) (rec ..x)
                         (eq '%%vm-go-nil e) (cons e (cons .x. (cons ..x. (cons (get-tag-index ...x.) (rec ....x)))))
                         (eq '%%vm-go e) (cons e (cons (get-tag-index .x.) (rec ..x)))
                         (cons e (rec .x)))))))
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
  (format t "Loading bytecode function ~A.~%" x.)
  (= (symbol-function x.) (late-print (list-array .x))))

(defun load-bytecode-functions (x)
  (map #'load-bytecode-function x)
  x)
