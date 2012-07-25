;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun get-tag-indexes (x)
  (with (indexes (make-queue)
         rec #'((x i)
                  (& x (? (%%tag? x.)
                          (progn
                            (enqueue indexes (cons .x. i))
                            (rec ..x i))
                          (rec .x (1+ i))))))
    (rec x 0)))

(defun translate-jumps (indexes x)
  (with (get-tag-index (fn assoc-value _ (queue-list indexes))
         rec #'((x)
                  (& x (?
                         (%%tag? x) (rec .x)
                         (vm-jump? x) (cons x. (? (%%vm-go-nil? x)
                                                  (cons ..x. (cons (get-tag-index .x.) (rec ...x)))
                                                  (cons (get-tag-index .x.) (rec ..x))))
                         (cons x. (rec .x))))))
    (list-array (rec x))))

(defun make-bytecode-function (fi x)
  (translate-jumps (get-tag-indexes x) x))

(defun get-next-function (x)
  (cdr (member '%%%bc-fun x :test #'eq)))

(defun expr-to-code (expr)
  (let-when x (get-next-function expr)
    (cons (make-bytecode-function (get-funinfo-by-sym .x.) (copy-while (fn not (eq _ '%%bc-return)) ..x))
          (expr-to-code (cdr (member '%%bc-return ..x :test #'eq))))))
